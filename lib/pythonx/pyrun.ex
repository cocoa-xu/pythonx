defmodule Pythonx.PyRun do
  @moduledoc false

  alias Pythonx.Beam
  alias Pythonx.Beam.PyObject
  alias Pythonx.State

  @spec string(String.t(), integer(), State.t()) :: {any(), State.t()}
  def string(str, start, state) do
    string(str, start, state.globals, state.locals)
  end

  @spec string(String.t(), integer(), map() | Keyword.t(), map() | Keyword.t()) ::
          PyObject.t()
  def string(str, start, globals, locals) do
    globals = Beam.encode(globals)
    locals = Beam.encode(locals)

    result =
      str
      |> Pythonx.C.PyRun.string(start, globals.ref, locals.ref)
      |> Pythonx.Beam.from_c_pyobject()

    locals = Beam.decode(locals)
    {result, %State{globals: globals, locals: locals}}
  end
end
