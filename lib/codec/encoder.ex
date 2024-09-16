defprotocol Pythonx.Codec.Encoder do
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyObject, as: CPyObject

  @doc """
  Encode a value to a Python object, return in `Pythonx.Beam.PyObject.t()`
  """
  @spec encode(value :: any()) :: PyObject.t() | PyErr.t()
  def encode(value)

  @doc """
  Encode a value to a Python object, return in `Pythonx.C.PyObject.t()`
  """
  @spec encode_c(value :: any()) :: CPyObject.t() | PyErr.t()
  def encode_c(value)
end

defimpl Pythonx.Codec.Encoder, for: Any do
  def encode(_) do
    raise RuntimeError, "Not implemented"
  end

  def encode_c(_) do
    raise RuntimeError, "Not implemented"
  end
end
