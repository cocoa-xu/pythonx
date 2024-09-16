defmodule Pythonx.Beam.PyDict do
  @moduledoc """
  Python dictionary
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PyDict do
  alias Pythonx.Beam.PyDict
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyDict, as: CPyDict
  alias Pythonx.C.PyList, as: CPyList

  def decode(%PyDict{ref: ref}) do
    keys = CPyDict.keys(ref)
    values = CPyDict.values(ref)
    size = CPyList.size(keys)

    Map.new(0..(size - 1), fn pos ->
      key = CPyList.get_item(keys, pos)
      value = CPyList.get_item(values, pos)
      {PyObject.decode(%PyObject{ref: key}), PyObject.decode(%PyObject{ref: value})}
    end)
  end
end
