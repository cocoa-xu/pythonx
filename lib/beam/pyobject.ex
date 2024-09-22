defmodule Pythonx.Beam.PyObject do
  @moduledoc """
  Python object in BEAM.
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{ref: CPyObject.t()}

  defstruct [
    :ref
  ]

  @doc """
  None.
  """
  def py_none do
    %__MODULE__{ref: CPyObject.py_none()}
  end

  @doc """
  True.
  """
  def py_true do
    %__MODULE__{ref: CPyObject.py_true()}
  end

  @doc """
  False.
  """
  def py_false do
    %__MODULE__{ref: CPyObject.py_false()}
  end

  @doc """
  Get type of object.
  """
  @spec type(t()) :: String.t()
  def type(%__MODULE__{ref: ref}) do
    obj_type = CPyObject.type(ref)

    if is_reference(obj_type) do
      type_name = CPyObject.get_attr_string(obj_type, "__name__")
      Pythonx.C.PyUnicode.as_utf8(type_name)
    else
      "unknown"
    end
  end

  def decode(%__MODULE__{} = val) do
    Pythonx.Codec.Decoder.decode(val)
  end

  def from_c_pyobject(ref) when is_reference(ref) do
    %__MODULE__{ref: ref}
  end

  def from_c_pyobject(err) do
    err
  end

  defimpl Inspect, for: Pythonx.Beam.PyObject do
    import Inspect.Algebra

    alias Pythonx.Beam.PyObject

    def inspect(%PyObject{ref: ref} = obj, opts) do
      type = PyObject.type(obj)
      flags = if type == "str", do: Pythonx.C.py_print_raw(), else: 0

      inner = [
        Inspect.List.keyword({:type, type}, opts),
        color(",", :map, opts),
        line(),
        Inspect.List.keyword({:repr, CPyObject.print(ref, flags)}, opts)
      ]

      concat([
        "#PyObject<",
        nest(
          concat([
            line(),
            concat(inner)
          ]),
          2
        ),
        line(),
        ">"
      ])
    end
  end
end

defimpl Pythonx.Codec.Decoder, for: Pythonx.Beam.PyObject do
  alias Pythonx.Beam.PyDict
  alias Pythonx.Beam.PyFloat
  alias Pythonx.Beam.PyList
  alias Pythonx.Beam.PyLong
  alias Pythonx.Beam.PyObject
  alias Pythonx.Beam.PyTuple
  alias Pythonx.Beam.PyUnicode
  alias Pythonx.C.PyObject, as: CPyObject

  def decode(obj) do
    type = PyObject.type(obj)

    case type do
      "NoneType" ->
        nil

      "bool" ->
        CPyObject.is_true(obj.ref)

      "str" ->
        Pythonx.Codec.Decoder.decode(%PyUnicode{ref: obj.ref})

      "int" ->
        Pythonx.Codec.Decoder.decode(%PyLong{ref: obj.ref})

      "float" ->
        Pythonx.Codec.Decoder.decode(%PyFloat{ref: obj.ref})

      "dict" ->
        Pythonx.Codec.Decoder.decode(%PyDict{ref: obj.ref})

      "list" ->
        Pythonx.Codec.Decoder.decode(%PyList{ref: obj.ref})

      "tuple" ->
        Pythonx.Codec.Decoder.decode(%PyTuple{ref: obj.ref})

      _ ->
        raise RuntimeError, "Not implemented yet for type #{type}"
    end
  end
end
