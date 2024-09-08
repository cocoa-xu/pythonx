defmodule Pythonx.C.PyList do
  @moduledoc """
  This subtype of PyObject represents a Python list object.
  """

  alias Pythonx.C.PyObject
  alias Pythonx.C.PyErr

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
  Return a new list of length len on success, or `nil` on failure.

  Note If len is greater than zero, the returned list object’s items are set to NULL.
  Thus you cannot use abstract API functions such as PySequence_SetItem() or expose
  the object to Python code before setting all items to a real object with PyList_SetItem().

  Return value: New reference.
  """
  @doc stable_api: true
  @spec new(integer()) :: PyObject.t() | nil
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
  def get_item(list, index) when is_reference(list) and is_integer(index),
    do: Pythonx.Nif.py_list_get_item(list, index)

  @doc """
  Set the item at index index in list to item. Return `true` on success.

  If index is out of bounds, return `PyErr` with an `IndexError` exception.

  Note: This function "steals" a reference to item and discards a reference
  to an item already in the list at the affected position.
  """
  @doc stable_api: true
  @spec set_item(PyObject.t(), integer(), PyObject.t()) :: true | PyErr.t()
  def set_item(list, index, item)
      when is_reference(list) and is_integer(index) and is_reference(item),
      do: Pythonx.Nif.py_list_set_item(list, index, item)

  @doc """
  Insert the item item into list `list` in front of index index.

  Return `true` if successful; return `PyErr` with an exception if unsuccessful.

  Analogous to list.insert(index, item).
  """
  @doc stable_api: true
  @spec insert(PyObject.t(), integer(), PyObject.t()) :: true | PyErr.t()
  def insert(list, index, item)
      when is_reference(list) and is_integer(index) and is_reference(item),
      do: Pythonx.Nif.py_list_insert(list, index, item)

  @doc """
  Append the object item at the end of list list.

  Return true if successful; return `PyErr` with an exception if unsuccessful.

  Analogous to list.append(item).
  """
  @doc stable_api: true
  @spec append(PyObject.t(), PyObject.t()) :: true | PyErr.t()
  def append(list, item) when is_reference(list) and is_reference(item),
    do: Pythonx.Nif.py_list_append(list, item)
end
