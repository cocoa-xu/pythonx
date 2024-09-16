defmodule Pythonx.Beam.PyLong do
  @moduledoc """
  Python pylong object
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PyLong do
  alias Pythonx.Beam.PyLong
  alias Pythonx.C.PyLong, as: CPyLong

  def decode(%PyLong{ref: ref}) do
    case CPyLong.as_long_long_and_overflow(ref) do
      {val, 0} ->
        val

      _ ->
        case CPyLong.as_unsigned_long_long(ref) do
          val when is_integer(val) -> val
          _ -> raise RuntimeError, "Cannot decode integer"
        end
    end
  end
end
