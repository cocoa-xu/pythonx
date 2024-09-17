defmodule Pythonx.C.PyErr do
  @moduledoc """
  Python Exception
  """

  alias Pythonx.C.PyObject

  @type t :: %__MODULE__{
          type: PyObject.t() | nil,
          value: PyObject.t() | nil,
          traceback: PyObject.t() | nil
        }

  defstruct [:type, :value, :traceback]

  @doc """
  Clear the error indicator. If the error indicator is not set, there is no effect.
  """
  @doc stable_api: true
  @spec clear :: :ok
  def clear, do: Pythonx.Nif.py_err_clear()
end
