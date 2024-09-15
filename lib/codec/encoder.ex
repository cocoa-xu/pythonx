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
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyObject, as: CPyObject

  @spec encode(any()) :: PyObject.t()
  def encode(_) do
    PyObject.from_c_pyobject(CPyObject.py_none())
  end

  @spec encode_c(any()) :: CPyObject.t()
  def encode_c(_) do
    Pythonx.C.PyObject.py_none()
  end
end
