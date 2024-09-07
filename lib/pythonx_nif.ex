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
              with ["win32"] <- target do
                ["x86_64", "windows", "msvc"]
              else
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
end
