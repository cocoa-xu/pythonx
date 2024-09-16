defmodule Pythonx.Beam do
  @moduledoc false

  alias Pythonx.Beam.PyObject

  def encode(%PyObject{} = value) do
    value
  end

  def encode(value) do
    Pythonx.Codec.Encoder.encode(value)
  end

  def decode(value) do
    Pythonx.Codec.Decoder.decode(value)
  end

  def from_c_pyobject(ref) when is_reference(ref) do
    Pythonx.Beam.PyObject.from_c_pyobject(ref)
  end

  def from_c_pyobject(%Pythonx.C.PyErr{} = error) do
    Pythonx.Beam.PyErr.from_c_pyobject(error)
  end

  defdelegate py_print_raw, to: Pythonx.C
  defdelegate py_eval_input, to: Pythonx.C
  defdelegate py_file_input, to: Pythonx.C
  defdelegate py_single_input, to: Pythonx.C
end
