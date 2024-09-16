defmodule Pythonx.Beam.PyFloat do
  @moduledoc """
  Python pyfloat object
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PyFloat do
  alias Pythonx.Beam.PyFloat
  alias Pythonx.C.PyFloat, as: CPyFloat

  def decode(%PyFloat{ref: ref}) do
    case CPyFloat.as_double(ref) do
      val when is_number(val) ->
        val

      _ ->
        raise RuntimeError, "Cannot decode double"
    end
  end
end
