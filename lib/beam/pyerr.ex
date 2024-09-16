defmodule Pythonx.Beam.PyErr do
  @moduledoc """
  Python Exception
  """

  alias Pythonx.Beam.PyObject

  @type t :: %__MODULE__{
          type: PyObject.t() | nil,
          value: PyObject.t() | nil,
          traceback: PyObject.t() | nil
        }

  defstruct [:type, :value, :traceback]

  def from_c_pyobject(%Pythonx.C.PyErr{} = err) do
    %__MODULE__{
      type: PyObject.from_c_pyobject(err.type),
      value: PyObject.from_c_pyobject(err.value),
      traceback: PyObject.from_c_pyobject(err.traceback)
    }
  end
end
