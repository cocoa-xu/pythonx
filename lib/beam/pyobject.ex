defmodule Pythonx.Beam.PyObject do
  @moduledoc """
  Python object in BEAM.
  """

  alias Pythonx.C.PyObject, as: CPyObject

  @type t :: %__MODULE__{ref: reference()}

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
      inner = [
        Inspect.List.keyword({:type, PyObject.type(obj)}, opts),
        color(",", :map, opts),
        line(),
        Inspect.List.keyword({:repr, CPyObject.print(ref, 0)}, opts)
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
