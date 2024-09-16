defmodule Pythonx.Beam.PyRun do
  @moduledoc false

  alias Pythonx.Beam.PyObject
  alias Pythonx.Beam.State

  @spec string(String.t(), integer(), State.t()) :: PyObject.t()
  def string(str, start, state) do
    string(str, start, state.globals, state.locals)
  end

  @spec string(String.t(), integer(), PyObject.t(), PyObject.t()) :: PyObject.t()
  def string(str, start, globals, locals) do
    str
    |> Pythonx.C.PyRun.string(start, globals.ref, locals.ref)
    |> Pythonx.Beam.from_c_pyobject()
  end
end
