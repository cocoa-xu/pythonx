defmodule Pythonx.C.PyObject do
  @moduledoc """
  Python Object
  """

  @type t :: reference()
  @type borrowed :: reference()

  @doc """
  Returns a reference to the Python None object.

  Only returns `:error` if it cannot allocate NIF resource for the object,
  for example, if the system is out of memory.
  """
  @spec py_none() :: reference() | :error
  def py_none, do: Pythonx.Nif.py_none()

  @doc """
  Returns a reference to the Python True object.

  Only returns `:error` if it cannot allocate NIF resource for the object,
  for example, if the system is out of memory.
  """
  @spec py_true() :: reference() | :error
  def py_true, do: Pythonx.Nif.py_true()

  @doc """
  Returns a reference to the Python False object.

  Only returns `:error` if it cannot allocate NIF resource for the object,
  for example, if the system is out of memory.
  """
  @spec py_false() :: reference() | :error
  def py_false, do: Pythonx.Nif.py_false()

  @doc """
  Increments the reference count for the object.
  """
  @spec incref(reference()) :: reference()
  def incref(ref), do: Pythonx.Nif.py_incref(ref)

  @doc """
  decrements the reference count for the object.
  """
  @spec decref(reference()) :: reference()
  def decref(ref), do: Pythonx.Nif.py_decref(ref)

  @doc """
  Print an object o.

  Returns -1 on error.

  The `flags` argument is used to enable certain printing options.

  The only option currently supported is `Pythonx.py_print_raw`;
  if given, the `str()` of the object is written instead of the `repr()`.
  """
  @spec print(PyObject.t()) :: String.t() | PyErr.t()
  def print(o), do: print(o, 0)

  @doc """
  Print an object o.

  Returns -1 on error.

  The `flags` argument is used to enable certain printing options.

  The only option currently supported is `Pythonx.py_print_raw`;
  if given, the `str()` of the object is written instead of the `repr()`.
  """
  @spec print(PyObject.t(), integer()) :: String.t() | PyErr.t()
  def print(o, flags), do: Pythonx.Nif.py_object_print(o, flags)

  @doc """
  Print an object o, on file `fp`.

  Returns -1 on error.

  The `flags` argument is used to enable certain printing options.

  The only option currently supported is `Pythonx.py_print_raw`;
  if given, the `str()` of the object is written instead of the `repr()`.
  """
  @spec print(PyObject.t(), :stdout | :stderr | IO.device(), integer()) :: String.t() | PyErr.t()
  def print(o, fp, flags) do
    ret = Pythonx.Nif.py_object_print(o, flags)

    if is_binary(ret) do
      case fp do
        :stdout -> IO.puts(ret)
        :stderr -> IO.puts(:stderr, ret)
        _ -> IO.write(fp, ret)
      end
    else
      ret
    end
  end

  @doc """
  Returns true if o has the attribute attr_name, and false otherwise.

  This is equivalent to the Python expression hasattr(o, attr_name). This function always succeeds.
  """
  @spec has_attr(reference(), reference()) :: boolean()
  def has_attr(ref, attr_name), do: Pythonx.Nif.py_object_has_attr(ref, attr_name)

  @doc """
  This is the same as `has_attr/2`, but `attr_name` is specified as a UTF-8 encoded bytes string, rather than a `PyObject`.
  """
  @spec has_attr_string(reference(), String.t()) :: boolean()
  def has_attr_string(ref, attr_name), do: Pythonx.Nif.py_object_has_attr_string(ref, attr_name)

  @doc """
  Retrieve an attribute named `attr_name` from object `o`.

  Returns the attribute value on success, or `nil` on failure.

  Only returns `:error` if it cannot allocate NIF resource for the object,
  for example, if the system is out of memory.

  This is the equivalent of the Python expression `o.attr_name`.
  """
  @spec get_attr(reference(), reference()) :: reference() | nil | :error
  def get_attr(o, attr_name), do: Pythonx.Nif.py_object_get_attr(o, attr_name)

  @doc """
  This is the same as `get_attr/2`, but `attr_name` is specified as a UTF-8 encoded bytes string, rather than a `PyObject`.
  """
  @spec get_attr_string(reference(), String.t()) :: reference() | nil | :error
  def get_attr_string(o, attr_name), do: Pythonx.Nif.py_object_get_attr_string(o, attr_name)

  @doc """
  Generic attribute getter function that is meant to be put into a type object’s `tp_getattro` slot.

  It looks for a descriptor in the dictionary of classes in the object’s MRO as well as an attribute in the object’s
  `__dict__` (if present). As outlined in Implementing Descriptors, data descriptors take preference over instance
  attributes, while non-data descriptors don’t. Otherwise, an `AttributeError` is raised.

  Only returns `:error` if it cannot allocate NIF resource for the object,
  for example, if the system is out of memory.
  """
  @spec generic_get_attr(reference(), reference()) :: reference() | PyErr.t() | :error
  def generic_get_attr(ref, attr_name), do: Pythonx.Nif.py_object_generic_get_attr(ref, attr_name)

  @doc """
  Set the value of the attribute named `attr_name`, for object `o`, to the value `v`.

  Returns `PyErr` on failure; return `true` on success.

  This is the equivalent of the Python statement `o.attr_name = v`.

  If v is `nil`, the attribute is deleted. This behaviour is deprecated in favour of using `del_attr/2`,
  but there are currently no plans to remove it.
  """
  @spec set_attr(reference(), reference(), reference() | nil) :: true | PyErr.t()
  def set_attr(o, attr_name, v), do: Pythonx.Nif.py_object_set_attr(o, attr_name, v)

  @doc """
  This is the same as `set_attr/3`, but `attr_name` is specified as a UTF-8 encoded bytes string, rather than a PyObject*.

  Returns `PyErr` on failure; return `true` on success.

  This is the equivalent of the Python statement `o.attr_name = v`.

  If v is `nil`, the attribute is deleted. This behaviour is deprecated in favour of using `del_attr/2`,
  but there are currently no plans to remove it.
  """
  @spec set_attr_string(reference(), String.t(), reference() | nil) :: true | PyErr.t()
  def set_attr_string(ref, attr_name, v), do: Pythonx.Nif.py_object_set_attr_string(ref, attr_name, v)

  @doc """
  Generic attribute setter and deleter function that is meant to be put into a type object’s `tp_setattro` slot.

  It looks for a data descriptor in the dictionary of classes in the object’s MRO, and if found it takes
  preference over setting or deleting the attribute in the instance dictionary. Otherwise, the attribute is set
  or deleted in the object’s `__dict__` (if present).

  On success, `true` is returned, otherwise an `AttributeError` is raised and `PyErr` is returned.
  """
  @spec generic_set_attr(reference(), reference(), reference()) :: true | PyErr.t()
  def generic_set_attr(ref, attr_name, v), do: Pythonx.Nif.py_object_generic_set_attr(ref, attr_name, v)

  @doc """
  Delete attribute named `attr_name`, for object `o`.

  Returns `false` on failure. This is the equivalent of the Python statement `del o.attr_name`.
  """
  @spec del_attr(reference(), reference()) :: boolean()
  def del_attr(o, attr_name), do: Pythonx.Nif.py_object_del_attr(o, attr_name)

  @doc """
  This is the same as `del_attr/2`, but `attr_name` is specified as a UTF-8 encoded bytes string, rather than a `PyObject`.
  """
  @spec del_attr_string(reference(), String.t()) :: boolean()
  def del_attr_string(o, attr_name), do: Pythonx.Nif.py_object_del_attr_string(o, attr_name)

  @doc """
  Compute a string representation of reference `o`.

  This is the equivalent of the Python expression `repr(o)`. Called by the `repr()` built-in function.

  ## Returns
  - reference to a new string representation object on success,
  - `PyErr` on failure,
  - `:error` only when it cannot allocate NIF resource for the object, for example, if the system is out of memory.
  """
  @spec repr(reference()) :: reference() | PyErr.t() | :error
  def repr(o), do: Pythonx.Nif.py_object_repr(o)

  @doc """
  As `repr/1`, compute a string representation of reference `o`,
  but escape the non-ASCII characters in the string returned by `repr/1`
  with `\\x`, `\\u` or `\\U` escapes.

  This generates a string similar to that returned by `PyObject_Repr()` in Python 2.
  Called by the `ascii()` built-in function.

  ## Returns
  - reference to a new string representation object on success,
  - `PyErr` on failure,
  - `:error` only when it cannot allocate NIF resource for the object, for example, if the system is out of memory.
  """
  @spec ascii(PyObject.t()) :: PyObject.t() | PyErr.t() | :error
  def ascii(o), do: Pythonx.Nif.py_object_ascii(o)

  @doc """
  Compute a string representation of reference `o`.

  This is the equivalent of the Python expression str(o). Called by the `str()` built-in function and,
  therefore, by the `print()` function.

  ## Returns
  - reference to a new string representation object on success,
  - `PyErr` on failure,
  - `:error` only when it cannot allocate NIF resource for the object, for example, if the system is out of memory.
  """
  @spec str(PyObject.t()) :: PyObject.t() | PyErr.t() | :error
  def str(o), do: Pythonx.Nif.py_object_str(o)

  @doc """
  Compute a bytes representation of reference `o`.

  This is the equivalent of the Python expression `bytes(o)`, when `o` is not an integer.

  Unlike `bytes(o)`, a `TypeError` is raised when `o` is an integer instead of a
  zero-initialized bytes object.

  ## Returns
  - reference to a new bytes representation object on success,
  - `PyErr` on failure,
  - `:error` only when it cannot allocate NIF resource for the object, for example, if the system is out of memory.
  """
  @spec bytes(PyObject.t()) :: PyObject.t() | PyErr.t() | :error
  def bytes(o), do: Pythonx.Nif.py_object_bytes(o)

  @doc """
  Returns `true` if the object `o` is considered to be `true`, and `false` otherwise.

  This is equivalent to the Python expression `not not o`. On failure, return `:error`.
  """
  @spec is_true(reference()) :: boolean() | :error
  def is_true(o), do: Pythonx.Nif.py_object_is_true(o)

  @doc """
  Returns `false` if the object `o` is considered to be `true`, and `true` otherwise.
  This is equivalent to the Python expression `not o`. On failure, return `:error`.
  """
  @spec not reference() :: boolean() | :error
  def not ref, do: Pythonx.Nif.py_object_not(ref)

  @doc """
  Returns a type object corresponding to the object type of object `o`.

  When `o` is non-`NULL`, returns a type object corresponding to the object
  type of object `o`.

  On failure, returns `PyErr` with `SystemError`. This is equivalent to the Python expression `type(o)`.

  This function creates a new strong reference to the return value.

  There’s really no reason to use this function instead of the `Pythonx.C.type/1` function, which returns
  a pointer of type `PyTypeObject*`, except when a new strong reference is needed.

  Only returns `:error` if it cannot allocate NIF resource for the object,
  for example, if the system is out of memory.
  """
  @spec type(reference()) :: reference() | PyErr.t() | :error
  def type(ref), do: Pythonx.Nif.py_object_type(ref)

  @doc """
  Return the length of object `o`. If the object `o` provides either the sequence
  and mapping protocols, the sequence length is returned.

  On error, `-1` is returned.

  This is the equivalent to the Python expression `len(o)`.
  """
  @spec length(reference()) :: integer()
  def length(o), do: Pythonx.Nif.py_object_length(o)
end
