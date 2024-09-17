defmodule Pythonx.Beam.PyNumber do
  @moduledoc """
  Python number protocol
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end
