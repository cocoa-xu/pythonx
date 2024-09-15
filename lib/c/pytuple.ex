defmodule Pythonx.C.PyTuple do
  @moduledoc """
  This subtype of PyObject represents a Python tuple object.
  """

  alias Pythonx.C.PyObject

  @doc """
  Return `true` if `p` is a tuple object or an instance of a subtype of the tuple type.

  This function always succeeds.
  """
  @spec check(PyObject.t()) :: boolean()
  def check(p) when is_reference(p), do: Pythonx.Nif.py_tuple_check(p)

  @doc """
  Return `true` if `p` is a tuple object, but not an instance of a subtype of the tuple type.

  This function always succeeds.
  """
  @spec check_exact(PyObject.t()) :: boolean()
  def check_exact(p) when is_reference(p), do: Pythonx.Nif.py_tuple_check_exact(p)

  @doc """
  Return a new tuple object of size `len`, or `PyErr` with an exception set on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec new(integer()) :: PyObject.t() | PyErr.t()
  def new(len) when is_integer(len), do: Pythonx.Nif.py_tuple_new(len)

  @doc """
  Take a pointer to a tuple object, and return the size of that tuple. On error, return `PyErr` and with an exception set.
  """
  @doc stable_api: true
  @spec size(PyObject.t()) :: integer() | PyErr.t()
  def size(p) when is_reference(p), do: Pythonx.Nif.py_tuple_size(p)

  @doc """
  Return the object at position `pos` in the tuple pointed to by `p`.

  If `pos` is negative or out of bounds, return `PyErr` with an `IndexError` exception.

  The returned reference is borrowed from the tuple `p` (that is: it is only valid as long
  as you hold a reference to `p`).

  To get a strong reference, use `Pythonx.C.new_ref/1` or `Pythonx.C.PySequence.get_item/2`.
  """
  @doc stable_api: true
  @spec get_item(PyObject.t(), integer()) :: PyObject.borrowed() | PyErr.t()
  def get_item(p, pos) when is_reference(p) and is_integer(pos), do: Pythonx.Nif.py_tuple_get_item(p, pos)

  @doc """
  Return the slice of the tuple pointed to by `p` between `low` and `high`, or `PyErr` with an exception set on failure.

  This is the equivalent of the Python expression `p[low:high]`.

  Indexing from the end of the tuple is not supported.
  """
  @doc stable_api: true
  @spec get_slice(PyObject.t(), integer(), integer()) :: PyObject.t() | PyErr.t()
  def get_slice(p, low, high) when is_reference(p) and is_integer(low) and is_integer(high),
    do: Pythonx.Nif.py_tuple_get_slice(p, low, high)

  # @doc """
  # Insert a reference to object `o` at position `pos` of the tuple pointed to by `p`.

  # Return `true` on success.

  # If `pos` is out of bounds, return `PyErr` with an `IndexError` exception.
  # """
  # @doc stable_api: true
  # @spec set_item(PyObject.t(), integer(), PyObject.t()) :: true | PyErr.t()
  # def set_item(p, pos, o) when is_reference(p) and is_integer(pos) and is_reference(o),
  #   do: Pythonx.Nif.py_tuple_set_item(p, pos, o)
end

defimpl Pythonx.Codec.Encoder, for: Tuple do
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyList
  alias Pythonx.Codec.Encoder

  @spec encode(Tuple.t()) :: PyObject.t() | PyErr.t()
  def encode(value) do
    value
    |> encode_c()
    |> PyObject.from_c_pyobject()
  end

  @spec encode_c(Tuple.t()) :: CPyObject.t()
  def encode_c(value) do
    as_list = Tuple.to_list(value)
    list = Encoder.encode_c(as_list)
    PyList.as_tuple(list)
  end
end
