defmodule Pythonx do
  @moduledoc """
  Documentation for `Pythonx`.
  """

  @doc """
  List all embedded python versions.
  """
  def list_python_versions, do: Pythonx.Nif.list_python_versions()

  @doc """
  Evaluates the given python code and returns the variables specified in the `return` option.
  """
  defmacro pyeval(code, opts) do
    vars = Keyword.get(opts, :return, [])
    opts = [locals: false, globals: false, return: vars]
    quoted_vars = Enum.map(vars, fn var -> Macro.var(var, nil) end)

    quote do
      [unquote_splicing(quoted_vars)] = Pythonx.inline!(unquote(code), unquote(opts))
    end
  end

  defmacro pyinline(code, opts \\ []) do
    vars = Keyword.get(opts, :return, [])
    opts = [locals: false, globals: false, return: vars]
    quoted_vars = Enum.map(vars, fn var -> Macro.var(var, nil) end)

    python3_root = "#{:code.priv_dir(:pythonx)}/python3"
    embedded_python3_executable = "#{python3_root}/bin/python3"

    envs =
      case :os.type() do
        {:unix, :darwin} ->
          [{"DYLD_INSERT_LIBRARIES", "#{python3_root}/lib/libpython3.dylib"}]

        {:unix, _} ->
          [{"LD_LIBRARY_PATH", "#{python3_root}/lib"}]

        _ ->
          []
      end

    args = [
      "-c",
      """
      import symtable
      import json

      def analyze_code(code):
          try:
              sym_table = symtable.symtable(code, '<string>', 'exec')
              def gather_symbols(table):
                  globals_used = set()
                  for symbol in table.get_symbols():
                      if symbol.is_global():
                          globals_used.add(symbol.get_name())
                  for child in table.get_children():
                      child_globals = gather_symbols(child)
                      globals_used.update(child_globals)
                  return globals_used
              return {"status": "ok", "globals": list(gather_symbols(sym_table))}
          except SyntaxError as e:
              return {"status": "error", "error": e.msg, "lineno": e.lineno, "offset": e.offset}

      code_snippet = \"\"\"
      #{String.replace(code, "\"", "\\\"")}
      \"\"\"

      print(json.dumps(analyze_code(code_snippet)))
      """
    ]

    get_globals = fn python3_executable ->
      case System.cmd(python3_executable, args, env: envs, stderr_to_stdout: true) do
        {outputs, 0} ->
          case Jason.decode(outputs) do
            {:ok, %{"status" => "ok", "globals" => globals}} ->
              {:ok, Macro.escape(Map.new(Enum.map(globals, fn global -> {global, true} end)))}

            {:ok,
             %{"status" => "error", "error" => error, "lineno" => lineno, "offset" => offset}} ->
              description = """
              The inline Python code contains syntax errors: #{error} at line #{__CALLER__.line + lineno}, column #{offset}
              """

              {:error,
               {CompileError,
                file: __CALLER__.file, line: __CALLER__.line + lineno, description: description}}

            _ ->
              description = """
              The inline Python code contains unknown errors. #{outputs}
              """

              {:error,
               {CompileError,
                file: __CALLER__.file, line: __CALLER__.line, description: description}}
          end

        {outputs, _} ->
          description = """
          Failed to analyze the inline python code: #{outputs}
          """

          {:error,
           {CompileError, file: __CALLER__.file, line: __CALLER__.line, description: description}}
      end
    end

    globals =
      case get_globals.(embedded_python3_executable) do
        {:error, {CompileError, reason}} ->
          case reason[:description] do
            "Failed to analyze" <> _ ->
              # Retry with the python3 executable from the host
              # as we can't use the python3 executable from the embedded python when cross-compiling
              case get_globals.(System.find_executable("python3")) do
                {:error, {CompileError, reason}} -> raise CompileError, reason
                {:ok, globals} -> globals
              end

            _ ->
              raise CompileError, reason
          end

        {:ok, globals} ->
          globals
      end

    quote do
      [unquote_splicing(quoted_vars)] =
        Pythonx.inline!(
          unquote(code),
          unquote(opts) ++
            [
              elixir_vars:
                Enum.reduce(binding(), [], fn {var_name, _} = val, acc ->
                  if Map.get(unquote(globals), "#{var_name}") do
                    [val | acc]
                  else
                    acc
                  end
                end)
            ]
        )
    end
  end

  @doc """
  Initializes the Python with the given path to `python_home`.

  This function must be called before any other function in this module.

  It's expected that the `python_home` is the path to the python3 directory, which contains the following
  directories and files:

  ```bash
  - bin
    - python3
    - python3.x
  - include
  - lib
    - python3.x
    - libpython3.x.so (on Linux)
    - libpython3.x.dylib (on macOS)
  ```

  It's also expected that this function to be called only once, and it must be called before any other function.
  """
  def initialize(python_home) do
    unless Pythonx.Nif.nif_loaded() do
      Pythonx.Nif.load_nif({:custom, python_home})
    end

    Pythonx.Nif.initialize(python_home)
  end

  def initialize do
    unless Pythonx.Nif.nif_loaded() do
      Pythonx.Nif.load_nif(:embedded)
    end

    Pythonx.Nif.initialize(python_home())
  end

  def initialize_once(python_home \\ python_home()) do
    unless Pythonx.Nif.nif_loaded() do
      Pythonx.Nif.load_nif(:embedded)
      Pythonx.Nif.initialize(python_home)
    end
  end

  def finalize do
    Pythonx.Nif.finalize()
  end

  @doc """
  Executes a command with the embedded python3 executable.
  """
  defmacro python3!(args, opts \\ []) do
    into =
      Keyword.get(
        opts,
        :into,
        quote do
          IO.stream()
        end
      )

    args = List.wrap(args)
    env = Keyword.get(opts, :env, [{"PYTHONHOME", Pythonx.python_home()}])

    quote do
      System.cmd(unquote(Pythonx.python3_executable()), unquote(args),
        into: unquote(into),
        env: unquote(env)
      )
    end
  end

  @doc """
  Executes a command with the embedded pip module.
  """
  defmacro pip!(args, opts \\ []) do
    into =
      Keyword.get(
        opts,
        :into,
        quote do
          IO.stream()
        end
      )

    args = List.wrap(args)
    env = Keyword.get(opts, :env, [{"PYTHONHOME", Pythonx.python_home()}])

    quote do
      System.cmd(unquote(Pythonx.python3_executable()), ["-m", "pip", unquote_splicing(args)],
        into: unquote(into),
        env: unquote(env)
      )
    end
  end

  @doc """
  Returns the value for `PYTHONHOME`.
  """
  def python_home do
    "#{:code.priv_dir(:pythonx)}/python3"
  end

  @doc """
  Returns the path to the python3 executable.
  """
  def python3_executable do
    Path.join([python_home(), "bin", "python3"])
  end

  def eval(code, opts \\ []) do
    vars = opts[:return] || []
    locals = opts[:locals] || false
    globals = opts[:globals] || false
    Pythonx.Nif.inline(code, vars, locals, globals, [])
  end

  def eval!(code, opts \\ []) do
    with {:ok, result} <- Pythonx.inline(code, opts) do
      result
    else
      {:error, reason} -> raise reason
    end
  end

  def inline(code, opts \\ []) do
    vars = opts[:return] || []
    locals = opts[:locals] || false
    globals = opts[:globals] || false
    elixir_vars = opts[:elixir_vars] || []
    Pythonx.Nif.inline(code, vars, locals, globals, elixir_vars)
  end

  def inline!(code, opts \\ []) do
    with {:ok, result} <- Pythonx.inline(code, opts) do
      result
    else
      {:error, reason} -> raise reason
    end
  end
end
