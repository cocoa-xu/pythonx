defmodule Pythonx.Beam.PyTuple do
  @moduledoc """
  Python tuple object
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PyTuple do
  alias Pythonx.Beam.PyObject
  alias Pythonx.Beam.PyTuple
  alias Pythonx.C.PyTuple, as: CPyTuple

  def decode(%PyTuple{ref: ref}) do
    size = CPyTuple.size(ref)

    Enum.reduce(0..(size - 1), [], fn pos, acc ->
      item = CPyTuple.get_item(ref, pos)
      [PyObject.decode(%PyObject{ref: item}) | acc]
    end)
    |> Enum.reverse()
    |> List.to_tuple()
  end
end
