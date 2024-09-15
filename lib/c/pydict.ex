defmodule Pythonx.C.PyDict do
  @moduledoc """
  This subtype of PyObject represents a Python dictionary object.
  """

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyObject

  @doc """
  Return `true` if `p` is a dict object or an instance of a subtype of the dict type.

  This function always succeeds.
  """
  @spec check(PyObject.t()) :: boolean()
  def check(p) when is_reference(p), do: Pythonx.Nif.py_dict_check(p)

  @doc """
  Return `true` if `p` is a dict object, but not an instance of a subtype of the dict type.

  This function always succeeds.
  """
  @spec check_exact(PyObject.t()) :: boolean()
  def check_exact(p) when is_reference(p), do: Pythonx.Nif.py_dict_check_exact(p)

  @doc """
  Return a new empty dictionary, or `PyErr` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec new() :: PyObject.t() | PyErr.t()
  def new(), do: Pythonx.Nif.py_dict_new()

  # @doc """
  # Empty an existing dictionary of all key-value pairs.
  # """
  # @doc stable_api: true
  # @spec clear(PyObject.t()) :: :ok
  # def clear(dict) when is_reference(dict), do: Pythonx.Nif.py_dict_clear(dict)

  # @doc """
  # Determine if dictionary `p` contains `key`. If an item in p is matches key, return `true`, otherwise return `false`.

  # On error, return `PyErr.t()`.

  # This is equivalent to the Python expression `key in p`.
  # """
  # @doc stable_api: true
  # @spec contains(PyObject.t(), PyObject.t()) :: boolean() | PyErr.t()
  # def contains(p, key) when is_reference(p) and is_reference(key), do: Pythonx.Nif.py_dict_contains(p, key)

  # @doc """
  # Return a new dictionary that contains the same key-value pairs as `p`.

  # Return value: New reference.
  # """
  # @doc stable_api: true
  # @spec copy(PyObject.t()) :: PyObject.t() | PyErr.t()
  # def copy(p) when is_reference(p), do: Pythonx.Nif.py_dict_copy(p)

  @doc """
  Insert `val` into the dictionary `p` with a key of `key`.

  `key` must be hashable; if it isn’t, `PyErr.t()` with `TypeError` will be returned.

  Return `:ok` on success or `PyErr.t()` on failure.

  This function does not steal a reference to `val`.
  """
  @doc stable_api: true
  @spec set_item(PyObject.t(), PyObject.t(), PyObject.t()) :: :ok | PyErr.t()
  def set_item(p, key, val) when is_reference(p) and is_reference(key) and is_reference(val), do: Pythonx.Nif.py_dict_set_item(p, key, val)

  @doc """
  This is the same as `PyDict.set_item/3`, but `key` is specified as a UTF-8 encoded binary string, rather than a `PyObject*`.
  """
  @doc stable_api: true
  @spec set_item_string(PyObject.t(), String.t(), PyObject.t()) :: :ok | PyErr.t()
  def set_item_string(p, key, val) when is_reference(p) and is_binary(key) and is_reference(val), do: Pythonx.Nif.py_dict_set_item_string(p, key, val)

  # @doc """
  # Remove the entry in dictionary `p` with key `key`.

  # `key` must be hashable; if it isn’t, `PyErr.t()` with `TypeError` will be returned.

  # If `key` is not in the dictionary, `PyErr.t()` with `KeyError` will be returned.

  # Return `true` on success or `PyErr.t()` on failure.
  # """
  # @doc stable_api: true
  # @spec del_item(PyObject.t(), PyObject.t()) :: :ok | PyErr.t()
  # def del_item(p, key) when is_reference(p) and is_reference(key), do: Pythonx.Nif.py_dict_del_item(p, key)

  # @doc """
  # This is the same as `PyDict.del_item/2`, but `key` is specified as a UTF-8 encoded binary string, rather than a `PyObject*`.
  # """
  # @doc stable_api: true
  # @spec del_item_string(PyObject.t(), String.t()) :: :ok | PyErr.t()
  # def del_item_string(p, key) when is_reference(p) and is_binary(key), do: Pythonx.Nif.py_dict_del_item_string(p, key)

  # @doc """
  # Return the object from dictionary `p` which has a key `key`.

  # Return `nil` if the key `key` is not present, but without setting an exception.

  # ### Note
  # Exceptions that occur while this calls `__hash__()` and `__eq__()` methods are silently ignored.

  # Prefer the `PyDict.get_item_with_error` function instead.

  # ### Warning
  # Changed in version 3.10:

  # Calling this API without GIL held had been allowed for historical reason. It is no longer allowed.

  # Return value: Borrowed reference
  # """
  # @doc stable_api: true
  # @spec get_item(PyObject.t(), PyObject.t()) :: PyObject.borrowed() | nil
  # def get_item(p, key) when is_reference(p) and is_reference(key), do: Pythonx.Nif.py_dict_get_item(p, key)

  # @doc """
  # Variant of `PyDict.get_item/2`() that does not suppress exceptions.

  # Return `PyErr.t()` with an exception set if an exception occurred.

  # Return `nil` without an exception set if the key wasn’t present.

  # Return value: Borrowed reference
  # """
  # @doc stable_api: true
  # @spec get_item_with_error(PyObject.t(), PyObject.t()) :: PyObject.borrowed() | nil | PyErr.t()
  # def get_item_with_error(p, key) when is_reference(p) and is_reference(key), do: Pythonx.Nif.py_dict_get_item_with_error(p, key)

  # @doc """
  # This is the same as `PyDict.get_item/2`, but `key` is specified as a UTF-8 encoded binary string, rather than a `PyObject*`.

  # ### Note
  # Exceptions that occur while this calls `__hash__()` and `__eq__()` methods or while creating the temporary `str` object are silently ignored.

  # Prefer using the `PyDict.get_item_with_error/2` function with your own `PyUnicode.from_string/1` `key` instead.
  # """
  # @doc stable_api: true
  # @spec get_item_string(PyObject.t(), String.t()) :: PyObject.borrowed() | nil
  # def get_item_string(p, key) when is_reference(p) and is_binary(key), do: Pythonx.Nif.py_dict_get_item_string(p, key)

  # @doc """
  # This is the same as the Python-level `dict.setdefault()`.

  # If present, it returns the value corresponding to `key` from the dictionary `p`.

  # If the key is not in the dict, it is inserted with value `defaultobj` and `defaultobj` is returned.

  # This function evaluates the hash function of key only once, instead of evaluating it independently for the lookup and the insertion.

  # Return value: Borrowed reference.
  # """
  # @doc stable_api: true
  # @spec set_default(PyObject.t(), PyObject.t(), PyObject.t()) :: PyObject.borrowed()
  # def set_default(p, key, defaultobj) when is_reference(p) and is_reference(key) and is_reference(defaultobj), do: Pythonx.Nif.py_dict_set_default(p, key, defaultobj)

  # @doc """
  # Return a PyListObject containing all the items from the dictionary.

  # Return value: New reference.
  # """
  # @doc stable_api: true
  # @spec items(PyObject.t()) :: PyObject.t() | PyErr.t()
  # def items(p) when is_reference(p), do: Pythonx.Nif.py_dict_items(p)

  # @doc """
  # Return a PyListObject containing all the keys from the dictionary.

  # Return value: New reference.
  # """
  # @doc stable_api: true
  # @spec keys(PyObject.t()) :: PyObject.t() | PyErr.t()
  # def keys(p) when is_reference(p), do: Pythonx.Nif.py_dict_keys(p)

  # @doc """
  # Return a PyListObject containing all the values from the dictionary p.

  # Return value: New reference.
  # """
  # @doc stable_api: true
  # @spec values(PyObject.t()) :: PyObject.t() | PyErr.t()
  # def values(p) when is_reference(p), do: Pythonx.Nif.py_dict_values(p)

  # @doc """
  # Return the number of items in the dictionary.

  # This is equivalent to `len(p)` on a dictionary.
  # """
  # @doc stable_api: true
  # @spec size(PyObject.t()) :: integer()
  # def size(p) when is_reference(p), do: Pythonx.Nif.py_dict_size(p)
end
