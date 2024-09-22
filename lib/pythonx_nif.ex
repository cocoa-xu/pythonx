defmodule Pythonx.Nif do
  @moduledoc false

  @doc """
  List all embedded python versions in the priv directory.
  """
  def list_python_versions do
    priv_dir()
    |> File.ls!()
    |> Enum.filter(fn version -> String.starts_with?(version, "python3.") end)
    |> Enum.map(fn version -> String.replace(version, "python", "") end)
  end

  @doc """
  Loads the NIF file with the given options.

  ## Keyword Parameters
  - `:with_python` - The python version to be used. It can be

    - a 2-tuple of `{:embedded, python_version}` or `{:custom, python_home}`,

      - for `{:embedded, python_version}`, it searches for the embedded python version in the priv directory,
        and if the version is not found, it will try to download the version from the GitHub, and then use it.

        If the version is not found in the priv directory, and the download fails, it will return an error.

      - for `{:custom, python_home}`, it uses the given python home directory.

    - `:embedded` - Uses the first embedded python version found in the priv directory.
  """
  def load_nif(with_python) do
    python_dir =
      case with_python do
        {:embedded, version} ->
          download_embedded_python!(version: version)

        {:custom, python_home} ->
          python_home

        :embedded ->
          version =
            case list_python_versions() do
              [] -> "3.8.16"
              [version | _] -> version
            end

          download_embedded_python!(version: version)
      end

    symbol_link_python_dir(python_dir)
    symbol_link_libpython3()

    nif_file = ~c"#{priv_dir()}/pythonx"

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> IO.puts("Failed to load nif: #{inspect(reason)}")
    end
  end

  def get_target do
    case System.get_env("MIX_TARGET") do
      "ios" ->
        {"aarch64-apple-darwin-ios", ["aarch64", "apple", "darwin"]}

      "xros" ->
        {"aarch64-apple-darwin-xros", ["aarch64", "apple", "darwin"]}

      _ ->
        target = String.split(to_string(:erlang.system_info(:system_architecture)), "-")

        [arch, os, abi] =
          case Enum.count(target) do
            3 ->
              target

            4 ->
              [arch, _vendor, os, abi] = target
              [arch, os, abi]

            1 ->
              case target do
                ["win32"] ->
                  ["x86_64", "windows", "msvc"]

                [unknown_target] ->
                  [unknown_target, "unknown", nil]
              end
          end

        abi =
          case abi do
            "darwin" <> _ ->
              "darwin"

            "win32" ->
              {compiler_id, _} = :erlang.system_info(:c_compiler_used)

              case compiler_id do
                :msc -> "msvc"
                _ -> to_string(compiler_id)
              end

            _ ->
              abi
          end

        arch =
          if os == "windows" do
            case String.downcase(System.get_env("PROCESSOR_ARCHITECTURE")) do
              "arm64" ->
                "aarch64"

              arch when arch in ["x64", "x86_64", "amd64"] ->
                "x86_64"

              arch ->
                arch
            end
          else
            arch
          end

        abi = System.get_env("TARGET_ABI", abi)
        os = System.get_env("TARGET_OS", os)

        arch =
          if String.match?(System.get_env("TARGET_CPU", ""), ~r/arm11[357]6/) do
            "armv6"
          else
            System.get_env("TARGET_ARCH", arch)
          end

        {Enum.join([arch, os, abi], "-"), [arch, os, abi]}
    end
  end

  def download_embedded_python!(opts \\ []) do
    version = Keyword.get(opts, :version, "3.8.16")
    force_redownload = Keyword.get(opts, :force_redownload, false)

    priv_dir = priv_dir()
    cache_dir = cache_dir()

    {target_triplet, _} = get_target()

    tarball_url =
      "https://github.com/cocoa-xu/libpython3-build/releases/download/v#{version}/libpython3-#{target_triplet}.tar.gz"

    python_target_dir = "python#{version}"
    python_dir = Path.join([priv_dir, python_target_dir])
    python_tar = Path.join([cache_dir, "pythonx-libpython#{version}-#{target_triplet}.tar.gz"])

    python_dir_exists = File.exists?(python_dir)

    if not python_dir_exists or force_redownload do
      File.mkdir_p!(cache_dir)
      File.rm_rf!(python_dir)
      resp = Req.get!(tarball_url)

      if resp.status == 200 do
        File.write!(python_tar, resp.body)
        tmp_dir = System.tmp_dir!()

        case :erl_tar.extract(python_tar, [:compressed, {:cwd, tmp_dir}]) do
          :ok ->
            File.rename!(Path.join([tmp_dir, "usr/local"]), python_dir)
            python_dir

          err ->
            raise RuntimeError,
                  "Failed to unarchive tarball file: #{python_tar}, error: #{inspect(err)}"
        end
      else
        raise RuntimeError, "Failed to download the embedded python tarball: #{tarball_url}"
      end
    else
      python_dir
    end
  end

  def symbol_link_python_dir(python_dir) do
    priv_dir = priv_dir()
    symbol_link_dir = "python3"

    python_dir =
      if String.starts_with?(python_dir, priv_dir) do
        Path.relative_to(python_dir, priv_dir)
      else
        python_dir
      end

    File.cd!(priv_dir, fn ->
      case File.read_link(symbol_link_dir) do
        {:ok, "/" <> _ = link} ->
          if link != python_dir do
            File.rm_rf!(symbol_link_dir)
            File.ln_s!(python_dir, symbol_link_dir)
          end

        {:ok, link} ->
          if Path.join(priv_dir, link) != python_dir do
            File.rm_rf!(symbol_link_dir)
            File.ln_s!(python_dir, symbol_link_dir)
          end

        {:error, _} ->
          File.rm_rf!(symbol_link_dir)
          File.ln_s!(python_dir, symbol_link_dir)
      end
    end)
  end

  def symbol_link_libpython3 do
    priv_dir = priv_dir()
    python3_dir = Path.join(priv_dir, "python3")
    lib_dir_ull = Path.join(python3_dir, "usr/local/lib")
    lib_dir_ul = Path.join(python3_dir, "usr/lib")
    lib_dir = Path.join(python3_dir, "lib")

    lib_dir =
      cond do
        File.exists?(lib_dir_ull) -> lib_dir_ull
        File.exists?(lib_dir_ul) -> lib_dir_ul
        File.exists?(lib_dir) -> lib_dir
        true -> raise RuntimeError, "Failed to find lib directory in #{python3_dir}"
      end

    file_ext =
      case :os.type() do
        {:unix, :darwin} ->
          "dylib"

        {:win32, _} ->
          "dll"

        _ ->
          "so"
      end

    libpython3 = Path.join(lib_dir, "libpython3.#{file_ext}")

    unless File.exists?(libpython3) do
      File.cd!(lib_dir, fn ->
        so_files =
          Enum.filter(File.ls!(), fn file ->
            String.match?(file, ~r/libpython3\..+\.#{file_ext}/)
          end)

        case so_files do
          [so_file | _] ->
            File.ln_s!(so_file, "libpython3.#{file_ext}")

          [] ->
            raise RuntimeError, "Failed to find any libpython3.x.#{file_ext} in #{lib_dir}"
        end
      end)
    end
  end

  def cache_dir do
    cache_opts = if System.get_env("MIX_XDG"), do: %{os: :linux}, else: %{}
    cache_dir = Path.join(:filename.basedir(:user_cache, "", cache_opts), "pythonx")

    cache_dir =
      System.get_env("PYTHONX_CACHE_DIR", Application.get_env(:pythonx, :cache_dir, cache_dir))

    File.mkdir_p!(cache_dir)
    cache_dir
  end

  defp priv_dir do
    "#{:code.priv_dir(:pythonx)}"
  end

  def initialize(_python_home), do: :erlang.nif_error(:not_loaded)
  def inline(_string, _vars, _locals, _globals, _binding), do: :erlang.nif_error(:not_loaded)
  def finalize, do: :erlang.nif_error(:not_loaded)
  def nif_loaded, do: false

  def py_none, do: :erlang.nif_error(:not_loaded)
  def py_true, do: :erlang.nif_error(:not_loaded)
  def py_false, do: :erlang.nif_error(:not_loaded)
  def py_incref(_ref), do: :erlang.nif_error(:not_loaded)
  def py_decref(_ref), do: :erlang.nif_error(:not_loaded)

  def py_dict_check(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_check_exact(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_new, do: :erlang.nif_error(:not_loaded)
  def py_dict_clear(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_contains(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_dict_copy(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_set_item(_ref, _key, _val), do: :erlang.nif_error(:not_loaded)
  def py_dict_set_item_string(_ref, _key, _val), do: :erlang.nif_error(:not_loaded)
  def py_dict_del_item(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_dict_del_item_string(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_dict_get_item(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_dict_get_item_with_error(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_dict_get_item_string(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_dict_set_default(_ref, _key, _default_val), do: :erlang.nif_error(:not_loaded)
  def py_dict_items(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_keys(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_values(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_size(_ref), do: :erlang.nif_error(:not_loaded)
  def py_dict_merge(_ref, _b, _override), do: :erlang.nif_error(:not_loaded)
  def py_dict_update(_ref, _b), do: :erlang.nif_error(:not_loaded)
  def py_dict_merge_from_seq2(_ref, _seq2, _override), do: :erlang.nif_error(:not_loaded)

  def py_err_clear, do: :erlang.nif_error(:not_loaded)

  def py_eval_get_builtins, do: :erlang.nif_error(:not_loaded)
  def py_eval_get_locals, do: :erlang.nif_error(:not_loaded)
  def py_eval_get_globals, do: :erlang.nif_error(:not_loaded)
  def py_eval_get_func_name(_func), do: :erlang.nif_error(:not_loaded)
  def py_eval_get_func_desc(_func), do: :erlang.nif_error(:not_loaded)

  def py_float_check(_ref), do: :erlang.nif_error(:not_loaded)
  def py_float_check_exact(_ref), do: :erlang.nif_error(:not_loaded)
  def py_float_from_string(_str), do: :erlang.nif_error(:not_loaded)
  def py_float_from_double(_v), do: :erlang.nif_error(:not_loaded)
  def py_float_as_double(_ref), do: :erlang.nif_error(:not_loaded)
  def py_float_get_info, do: :erlang.nif_error(:not_loaded)
  def py_float_get_max, do: :erlang.nif_error(:not_loaded)
  def py_float_get_min, do: :erlang.nif_error(:not_loaded)

  def py_list_check(_ref), do: :erlang.nif_error(:not_loaded)
  def py_list_check_exact(_ref), do: :erlang.nif_error(:not_loaded)
  def py_list_new(_len), do: :erlang.nif_error(:not_loaded)
  def py_list_size(_list), do: :erlang.nif_error(:not_loaded)
  def py_list_get_item(_list, _index), do: :erlang.nif_error(:not_loaded)
  def py_list_set_item(_list, _index, _item), do: :erlang.nif_error(:not_loaded)
  def py_list_insert(_list, _index, _item), do: :erlang.nif_error(:not_loaded)
  def py_list_append(_list, _item), do: :erlang.nif_error(:not_loaded)
  def py_list_get_slice(_list, _low, _high), do: :erlang.nif_error(:not_loaded)
  def py_list_set_slice(_list, _low, _high, _itemlist), do: :erlang.nif_error(:not_loaded)
  def py_list_sort(_list), do: :erlang.nif_error(:not_loaded)
  def py_list_reverse(_list), do: :erlang.nif_error(:not_loaded)
  def py_list_as_tuple(_list), do: :erlang.nif_error(:not_loaded)

  def py_long_check(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_check_exact(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_from_long(_v), do: :erlang.nif_error(:not_loaded)
  def py_long_from_unsigned_long(_v), do: :erlang.nif_error(:not_loaded)
  def py_long_from_ssize_t(_v), do: :erlang.nif_error(:not_loaded)
  def py_long_from_size_t(_v), do: :erlang.nif_error(:not_loaded)
  def py_long_from_long_long(_v), do: :erlang.nif_error(:not_loaded)
  def py_long_from_unsigned_long_long(_v), do: :erlang.nif_error(:not_loaded)
  def py_long_from_double(_v), do: :erlang.nif_error(:not_loaded)
  def py_long_from_string(_v, _base), do: :erlang.nif_error(:not_loaded)
  def py_long_as_long(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_long_and_overflow(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_long_long(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_long_long_and_overflow(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_ssize_t(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_unsigned_long(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_size_t(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_unsigned_long_long(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_unsigned_long_mask(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_unsigned_long_long_mask(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_as_double(_ref), do: :erlang.nif_error(:not_loaded)
  def py_long_get_info, do: :erlang.nif_error(:not_loaded)

  def py_number_check(_ref), do: :erlang.nif_error(:not_loaded)
  def py_number_add(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_subtract(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_multiply(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_matrix_multiply(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_floor_divide(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_true_divide(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_remainder(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_divmod(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_power(_o1, _o2, _o3), do: :erlang.nif_error(:not_loaded)
  def py_number_negative(_o), do: :erlang.nif_error(:not_loaded)
  def py_number_positive(_o), do: :erlang.nif_error(:not_loaded)
  def py_number_absolute(_o), do: :erlang.nif_error(:not_loaded)
  def py_number_invert(_o), do: :erlang.nif_error(:not_loaded)
  def py_number_lshift(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_rshift(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_and(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_xor(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_or(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_add(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_subtract(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_multiply(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_matrix_multiply(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_floor_divide(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_true_divide(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_remainder(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_power(_o1, _o2, _o3), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_lshift(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_rshift(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_and(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_xor(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_in_place_or(_o1, _o2), do: :erlang.nif_error(:not_loaded)
  def py_number_long(_o), do: :erlang.nif_error(:not_loaded)
  def py_number_float(_o), do: :erlang.nif_error(:not_loaded)
  def py_number_index(_o), do: :erlang.nif_error(:not_loaded)
  def py_number_to_base(_n, _base), do: :erlang.nif_error(:not_loaded)
  def py_number_as_ssize_t(_o, _exc), do: :erlang.nif_error(:not_loaded)

  def py_index_check(_o), do: :erlang.nif_error(:not_loaded)

  def py_object_print(_ref, _flags), do: :erlang.nif_error(:not_loaded)
  def py_object_has_attr(_ref, _attr_name), do: :erlang.nif_error(:not_loaded)
  def py_object_has_attr_string(_ref, _attr_name), do: :erlang.nif_error(:not_loaded)
  def py_object_get_attr(_ref, _attr_name), do: :erlang.nif_error(:not_loaded)
  def py_object_get_attr_string(_ref, _attr_name), do: :erlang.nif_error(:not_loaded)
  def py_object_generic_get_attr(_ref, _attr_name), do: :erlang.nif_error(:not_loaded)
  def py_object_set_attr(_ref, _attr_name, _v), do: :erlang.nif_error(:not_loaded)
  def py_object_set_attr_string(_ref, _attr_name, _v), do: :erlang.nif_error(:not_loaded)
  def py_object_generic_set_attr(_ref, _attr_name, _v), do: :erlang.nif_error(:not_loaded)
  def py_object_del_attr(_ref, _attr_name), do: :erlang.nif_error(:not_loaded)
  def py_object_del_attr_string(_ref, _attr_name), do: :erlang.nif_error(:not_loaded)
  def py_object_is_true(_ref), do: :erlang.nif_error(:not_loaded)
  def py_object_not(_ref), do: :erlang.nif_error(:not_loaded)
  def py_object_type(_ref), do: :erlang.nif_error(:not_loaded)
  def py_object_length(_ref), do: :erlang.nif_error(:not_loaded)
  def py_object_repr(_ref), do: :erlang.nif_error(:not_loaded)
  def py_object_ascii(_ref), do: :erlang.nif_error(:not_loaded)
  def py_object_str(_ref), do: :erlang.nif_error(:not_loaded)
  def py_object_bytes(_ref), do: :erlang.nif_error(:not_loaded)

  def py_set_check(_ref), do: :erlang.nif_error(:not_loaded)
  def py_set_new(_iterable), do: :erlang.nif_error(:not_loaded)
  def py_set_size(_ref), do: :erlang.nif_error(:not_loaded)
  def py_set_contains(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_set_add(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_set_discard(_ref, _key), do: :erlang.nif_error(:not_loaded)
  def py_set_pop(_ref), do: :erlang.nif_error(:not_loaded)
  def py_set_clear(_ref), do: :erlang.nif_error(:not_loaded)

  def py_tuple_check(_ref), do: :erlang.nif_error(:not_loaded)
  def py_tuple_check_exact(_ref), do: :erlang.nif_error(:not_loaded)
  def py_tuple_new(_len), do: :erlang.nif_error(:not_loaded)
  def py_tuple_size(_p), do: :erlang.nif_error(:not_loaded)
  def py_tuple_get_item(_p, _pos), do: :erlang.nif_error(:not_loaded)
  def py_tuple_get_slice(_p, _low, _high), do: :erlang.nif_error(:not_loaded)
  # def py_tuple_set_item(_p, _pos, _o), do: :erlang.nif_error(:not_loaded)

  def py_unicode_from_string(_string), do: :erlang.nif_error(:not_loaded)
  def py_unicode_as_utf8(_ref), do: :erlang.nif_error(:not_loaded)

  def py_run_simple_string(_command), do: :erlang.nif_error(:not_loaded)
  def py_run_string(_str, _start, _globals, _locals), do: :erlang.nif_error(:not_loaded)

  def py_print_raw, do: :erlang.nif_error(:not_loaded)
  def py_eval_input, do: :erlang.nif_error(:not_loaded)
  def py_file_input, do: :erlang.nif_error(:not_loaded)
  def py_single_input, do: :erlang.nif_error(:not_loaded)
end
