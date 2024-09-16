defmodule Pythonx.Beam.PyList do
  @moduledoc """
  Python list
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PyList do
  alias Pythonx.Beam.PyList
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyList, as: CPyList

  def decode(%PyList{ref: ref}) do
    size = CPyList.size(ref)

    Enum.reduce(0..(size - 1), [], fn pos, acc ->
      item = CPyList.get_item(ref, pos)
      [PyObject.decode(%PyObject{ref: item}) | acc]
    end)
    |> Enum.reverse()
  end
end
