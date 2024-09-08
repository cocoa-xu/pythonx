defmodule Pythonx.Raw.PyErr do
  @moduledoc """
  Python Exception
  """

  alias Pythonx.Raw.PyObject

  @type t :: %__MODULE__{
          type: PyObject.t() | nil,
          value: PyObject.t() | nil,
          traceback: PyObject.t() | nil
        }

  defstruct [:type, :value, :traceback]
end
