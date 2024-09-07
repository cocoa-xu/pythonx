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

    quote do
      [unquote_splicing(quoted_vars)] = Pythonx.inline!(unquote(code), unquote(opts) ++ [binding: binding()])
    end
  end

  @doc """
  Inline Python code.
  """
  def inline_py do
    Pythonx.initialize_once()

    a = 1
    pyinline """
    a = 2 + a
    """, return: [:a]
    a
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
    binding = opts[:binding] || []
    Pythonx.Nif.inline(code, vars, locals, globals, binding)
  end

  def inline!(code, opts \\ []) do
    with {:ok, result} <- Pythonx.inline(code, opts) do
      result
    else
      {:error, reason} -> raise reason
    end
  end
end
