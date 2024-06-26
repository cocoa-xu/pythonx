defmodule Pythonx do
  @moduledoc """
  Documentation for `Pythonx`.
  """

  defmacro pyeval(code, opts) do
    vars = Keyword.get(opts, :return, [])
    opts = [locals: false, globals: false, return: vars]
    quoted_vars = Enum.map(vars, fn var -> Macro.var(var, nil) end)
    quote do
      [unquote_splicing(quoted_vars)] = Pythonx.eval!(unquote(code), unquote(opts))
    end
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

  def test do
    eval!("""
    x = 5
    y = 6
    z = (x, y)
    import math
    (1,2)
    """)
  end
end
