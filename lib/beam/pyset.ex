defmodule Pythonx.Beam.PySet do
  @moduledoc """
  Python set object
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{
          ref: CPyObject.t()
        }

  defstruct [:ref]
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PySet do
  alias Pythonx.Beam.PyObject
  alias Pythonx.Beam.PySet
  alias Pythonx.C.PySet, as: CPySet

  def decode(%PySet{ref: ref}) do
    size = CPySet.size(ref)

    0..(size - 1)
    |> Enum.map(fn _i ->
      CPySet.pop(ref)
    end)
    |> MapSet.new(fn key ->
      CPySet.add(ref, key)
      Pythonx.Beam.decode(%PyObject{ref: key})
    end)
  end
end
