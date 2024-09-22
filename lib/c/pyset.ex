defmodule Pythonx.C.PySet do
  @moduledoc """
  Set Objects
  """

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyObject

  @doc """
  Return `true` if `p` is a set object or an instance of a subtype.

  This function always succeeds.
  """
  @doc stable_api: true
  @spec check(PyObject.t()) :: boolean()
  def check(p), do: Pythonx.Nif.py_set_check(p)

  @doc """
  Return a new set containing objects returned by the `iterable`.

  The `iterable` may be `nil` to create a new empty set.

  Return the new set on success or `PyErr.t()` on failure with `TypeError` if `iterable` is not actually iterable.

  The constructor is also useful for copying a set (`c=set(s)`).

  Return value: New reference.
  """
  @doc stable_api: true
  @spec new(PyObject.t() | nil) :: PyObject.t() | PyErr.t()
  def new(iterable) when is_reference(iterable) or is_nil(iterable), do: Pythonx.Nif.py_set_new(iterable)

  @doc """
  Return the length of a `set` or `frozenset` object.

  Equivalent to `len(anyset)`. Return `PyErr.t()` with `SystemError` if `anyset` is not
  a set, frozenset, or an instance of a subtype.
  """
  @doc stable_api: true
  @spec size(PyObject.t()) :: integer() | PyErr.t()
  def size(anyset), do: Pythonx.Nif.py_set_size(anyset)

  @doc """
  Return `true` if found, `false` if not found, and `PyErr.t()` if an error is encountered.

  Unlike the Python `__contains__()` method, this function does not automatically convert unhashable
  sets into temporary frozensets.

  Return `PyErr.t()` with a `TypeError` if the key is unhashable.

  Return `PyErr.t()` with `SystemError` if anyset is not a set, frozenset, or an instance of a subtype.
  """
  @doc stable_api: true
  @spec contains(PyObject.t(), PyObject.t()) :: boolean() | PyErr.t()
  def contains(anyset, key), do: Pythonx.Nif.py_set_contains(anyset, key)

  @doc """
  Add `key` to a `set` instance.

  Also works with frozenset instances (like `PyTuple.set_item/2` it can be used to fill in the values of
  brand new frozensets before they are exposed to other code).

  Return `true` on success or `PyErr.t()` on failure.

  Return `PyErr.t()` with a `TypeError` if the key is unhashable.

  Return `PyErr.t()` with a `MemoryError` if there is no room to grow.

  Return `PyErr.t()` with a `SystemError` if set is not an instance of set or its subtype.
  """
  @doc stable_api: true
  @spec add(PyObject.t(), PyObject.t()) :: true | PyErr.t()
  def add(set, key), do: Pythonx.Nif.py_set_add(set, key)

  @doc """
  Return `true` if found and removed, `false` if not found (no action taken), and `PyErr.t()` if an error is encountered.

  Does not return `PyErr.t()` with `KeyError` for missing keys.

  Return `PyErr.t()` with a `TypeError` if the key is unhashable. Unlike the Python `discard()` method, this function does
  not automatically convert unhashable sets into temporary frozensets.

  Raise `PyErr.t()` with a `SystemError` if set is not an instance of set or its subtype.
  """
  @doc stable_api: true
  @spec discard(PyObject.t(), PyObject.t()) :: boolean() | PyErr.t()
  def discard(set, key), do: Pythonx.Nif.py_set_discard(set, key)

  @doc """
  Return a new reference to an arbitrary object in the set, and removes the object from the set.

  Return `PyErr.t()` on failure.

  Return `PyErr.t()` with a `KeyError` if the set is empty.

  Return `PyErr.t()` with a `SystemError` if set is not an instance of set or its subtype.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec pop(PyObject.t()) :: PyObject.t() | PyErr.t()
  def pop(set), do: Pythonx.Nif.py_set_pop(set)

  @doc """
  Empty an existing set of all elements.

  Return `true` on success. Return `PyErr.t()` with a `SystemError` if set is not an instance of set or its subtype.
  """
  @doc stable_api: true
  @spec clear(PyObject.t()) :: true | PyErr.t()
  def clear(set), do: Pythonx.Nif.py_set_clear(set)
end
