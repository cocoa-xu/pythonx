defmodule Pythonx.C.PyUnicode do
  @moduledoc """
  Unicode Objects
  """

  @doc """
  Create a Unicode object from a UTF-8 encoded null-terminated char buffer str.
  """
  @spec from_string(iodata() | list()) :: reference()
  def from_string(string) do
    Pythonx.Nif.py_unicode_from_string(IO.iodata_to_binary(string))
  end

  @doc """
  Returns a reference to a Python Unicode object.
  """
  @spec as_utf8(reference()) :: binary() | :error
  def as_utf8(ref), do: Pythonx.Nif.py_unicode_as_utf8(ref)
end

defimpl Pythonx.Codec.Encoder, for: Atom do
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyObject, as: CPyObject
  alias Pythonx.C.PyUnicode

  @spec encode(atom()) :: PyObject.t() | PyErr.t()
  def encode(value) when is_atom(value) do
    value
    |> encode_c()
    |> PyObject.from_c_pyobject()
  end

  @spec encode_c(atom()) :: CPyObject.t() | PyErr.t()
  def encode_c(value) when is_atom(value) do
    PyUnicode.from_string("#{value}")
  end
end

defimpl Pythonx.Codec.Encoder, for: BitString do
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyObject, as: CPyObject
  alias Pythonx.C.PyUnicode

  @spec encode(binary()) :: PyObject.t() | PyErr.t()
  def encode(value) when is_binary(value) do
    value
    |> encode_c()
    |> PyObject.from_c_pyobject()
  end

  @spec encode_c(binary()) :: CPyObject.t() | PyErr.t()
  def encode_c(value) when is_binary(value) do
    PyUnicode.from_string(value)
  end
end
