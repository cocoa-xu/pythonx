defmodule Pythonx.Beam.PyUnicode do
  @moduledoc """
  Python unicode object
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PyUnicode do
  alias Pythonx.Beam.PyUnicode
  alias Pythonx.C.PyUnicode, as: CPyUnicode

  def decode(%PyUnicode{ref: ref}) do
    CPyUnicode.as_utf8(ref)
  end
end
