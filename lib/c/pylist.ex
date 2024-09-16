defmodule Pythonx.C.PyList do
  @moduledoc """
  This subtype of PyObject represents a Python list object.
  """

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyObject

  @doc """
  Return true if `p` is a list object or an instance of a subtype of the list type.

  This function always succeeds.
  """
  @spec check(PyObject.t()) :: boolean()
  def check(p) when is_reference(p), do: Pythonx.Nif.py_list_check(p)

  @doc """
  Return true if `p` is a list object, but not an instance of a subtype of the list type.

  This function always succeeds.
  """
  @spec check_exact(PyObject.t()) :: boolean()
  def check_exact(p) when is_reference(p), do: Pythonx.Nif.py_list_check_exact(p)

  @doc """
  Return a new list of length len on success, or `PyErr` on failure.

  ### Note
  If len is greater than zero, the returned list object’s items are set to NULL.
  Thus you cannot use abstract API functions such as PySequence_SetItem() or expose
  the object to Python code before setting all items to a real object with PyList_SetItem().

  Return value: New reference.
  """
  @doc stable_api: true
  @spec new(integer()) :: PyObject.t() | PyErr.t()
  def new(len) when is_integer(len), do: Pythonx.Nif.py_list_new(len)

  @doc """
  Return the length of the list object in list; this is equivalent to len(list) on a list object.
  """
  @doc stable_api: true
  @spec size(PyObject.t()) :: integer()
  def size(list) when is_reference(list), do: Pythonx.Nif.py_list_size(list)

  @doc """
  Return the object at position index in the list pointed to by list.

  The position must be non-negative; indexing from the end of the list is not supported.

  If index is out of bounds (<0 or >=len(list)), return `PyErr`

  Return value: Borrowed reference.
  """
  @doc stable_api: true
  @spec get_item(PyObject.t(), integer()) :: PyObject.borrowed() | PyErr.t()
  def get_item(list, index) when is_reference(list) and is_integer(index), do: Pythonx.Nif.py_list_get_item(list, index)

  @doc """
  Set the item at index index in list to item. Return `true` on success.

  If index is out of bounds, return `PyErr` with an `IndexError` exception.

  Note: This function "steals" a reference to item and discards a reference
  to an item already in the list at the affected position.
  """
  @doc stable_api: true
  @spec set_item(PyObject.t(), integer(), PyObject.t()) :: true | PyErr.t()
  def set_item(list, index, item) when is_reference(list) and is_integer(index) and is_reference(item),
    do: Pythonx.Nif.py_list_set_item(list, index, item)

  @doc """
  Insert the item item into list `list` in front of index index.

  Return `true` if successful; return `PyErr` with an exception if unsuccessful.

  Analogous to list.insert(index, item).
  """
  @doc stable_api: true
  @spec insert(PyObject.t(), integer(), PyObject.t()) :: true | PyErr.t()
  def insert(list, index, item) when is_reference(list) and is_integer(index) and is_reference(item),
    do: Pythonx.Nif.py_list_insert(list, index, item)

  @doc """
  Append the object item at the end of list list.

  Return true if successful; return `PyErr` with an exception if unsuccessful.

  Analogous to list.append(item).
  """
  @doc stable_api: true
  @spec append(PyObject.t(), PyObject.t()) :: true | PyErr.t()
  def append(list, item) when is_reference(list) and is_reference(item), do: Pythonx.Nif.py_list_append(list, item)

  @doc """
  Return a list of the objects in `list` containing the objects between `low` and `high`.

  Return `PyErr` with an exception if unsuccessful.

  Analogous to `list[low:high]`.

  Indexing from the end of the list is not supported.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec get_slice(PyObject.t(), integer(), integer()) :: PyObject.t() | PyErr.t()
  def get_slice(list, low, high) when is_reference(list) and is_integer(low) and is_integer(high),
    do: Pythonx.Nif.py_list_get_slice(list, low, high)

  @doc """
  Set the slice of `list` between `low` and `high` to the contents of `itemlist`.

  Analogous to `list[low:high] = itemlist`.

  The `itemlist` may be `nil`, indicating the assignment of an empty list (slice deletion).

  Return `true` on success, `false` on failure.

  Indexing from the end of the list is not supported.
  """
  @doc stable_api: true
  @spec set_slice(PyObject.t(), integer(), integer(), PyObject.t() | nil) :: boolean()
  def set_slice(list, low, high, itemlist)
      when is_reference(list) and is_integer(low) and is_integer(high) and (is_reference(itemlist) or is_nil(itemlist)),
      do: Pythonx.Nif.py_list_set_slice(list, low, high, itemlist)

  @doc """
  Sort the items of list in place.

  Return `true` on success, `false` on failure.

  This is equivalent to `list.sort()`.
  """
  @doc stable_api: true
  @spec sort(PyObject.t()) :: boolean()
  def sort(list) when is_reference(list), do: Pythonx.Nif.py_list_sort(list)

  @doc """
  Reverse the items of list in place.

  Return `true` on success, `false` on failure.

  This is equivalent to `list.reverse()`.
  """
  @doc stable_api: true
  @spec reverse(PyObject.t()) :: boolean()
  def reverse(list) when is_reference(list), do: Pythonx.Nif.py_list_reverse(list)

  @doc """
  Return a new tuple object containing the contents of `list`;

  equivalent to `tuple(list)`.

  Return value: New reference
  """
  @doc stable_api: true
  @spec as_tuple(PyObject.t()) :: PyObject.t() | PyErr.t()
  def as_tuple(list) when is_reference(list), do: Pythonx.Nif.py_list_as_tuple(list)
end

defimpl Pythonx.Codec.Encoder, for: List do
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyDict
  alias Pythonx.C.PyList
  alias Pythonx.C.PyObject, as: CPyObject
  alias Pythonx.Codec.Encoder

  @spec encode(list()) :: PyObject.t() | PyErr.t()
  def encode(value) when is_list(value) do
    value
    |> encode_c()
    |> PyObject.from_c_pyobject()
  end

  @spec encode_c(list()) :: CPyObject.t() | PyErr.t()
  def encode_c(value) when is_list(value) do
    if Keyword.keyword?(value) do
      dict = PyDict.new()

      Enum.each(value, fn {key, val} ->
        PyDict.set_item(dict, Encoder.encode_c(key), Encoder.encode_c(val))
      end)

      dict
    else
      Enum.reduce(value, PyList.new(0), fn item, list ->
        PyList.append(list, Encoder.encode_c(item))
        list
      end)
    end
  end
end
