defmodule Pythonx do
  @moduledoc """
  Documentation for `Pythonx`.
  """

  @doc """
  Evaluates the given python code and returns the variables specified in the `return` option.
  """
  defmacro pyeval(code, opts) do
    vars = Keyword.get(opts, :return, [])
    opts = [locals: false, globals: false, return: vars]
    quoted_vars = Enum.map(vars, fn var -> Macro.var(var, nil) end)

    quote do
      [unquote_splicing(quoted_vars)] = Pythonx.eval!(unquote(code), unquote(opts))
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
    Pythonx.Nif.eval(code, vars, locals, globals)
  end

  def eval!(code, opts \\ []) do
    vars = opts[:return] || []
    locals = opts[:locals] || false
    globals = opts[:globals] || false

    with {:ok, result} <- Pythonx.Nif.eval(code, vars, locals, globals) do
      result
    else
      {:error, reason} -> raise reason
    end
  end
end
