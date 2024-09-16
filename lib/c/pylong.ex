defmodule Pythonx.C.PyLong do
  @moduledoc """
  All integers are implemented as `PyLong.t()` integer objects of arbitrary size.
  """

  @doc """
  Return `true` if its argument is a PyLongObject or a subtype of PyLongObject.

  This function always succeeds.
  """
  @spec check(PyObject.t()) :: boolean()
  def check(p) when is_reference(p), do: Pythonx.Nif.py_long_check(p)

  @doc """
  Return `true` if its argument is a PyLongObject, but not a subtype of PyLongObject.

  This function always succeeds.
  """
  @spec check_exact(PyObject.t()) :: boolean()
  def check_exact(p) when is_reference(p), do: Pythonx.Nif.py_long_check_exact(p)

  @doc """
  Return a new PyLongObject object from `v`, or `nil` on failure.

  The current Python implementation keeps an array of integer objects for all integers between `-5` and `256`.
  When you create an int in that range you actually just get back a reference to the existing object.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_long(integer()) :: PyObject.t() | nil
  def from_long(v) when is_integer(v), do: Pythonx.Nif.py_long_from_long(v)

  @doc """
  Return a new PyLongObject object from a C `unsigned long`, or `nil` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_unsigned_long(non_neg_integer()) :: PyObject.t() | nil
  def from_unsigned_long(v) when is_integer(v) and v >= 0, do: Pythonx.Nif.py_long_from_unsigned_long(v)

  @doc """
  Return a new PyLongObject object from a C `Py_ssize_t`, or `nil` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_ssize_t(integer()) :: PyObject.t() | nil
  def from_ssize_t(v) when is_integer(v), do: Pythonx.Nif.py_long_from_ssize_t(v)

  @doc """
  Return a new PyLongObject object from a C `size_t`, or `nil` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_size_t(non_neg_integer()) :: PyObject.t() | nil
  def from_size_t(v) when is_integer(v) and v >= 0, do: Pythonx.Nif.py_long_from_size_t(v)

  @doc """
  Return a new PyLongObject object from a C `long long`, or `nil` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_long_long(integer()) :: PyObject.t() | nil
  def from_long_long(v) when is_integer(v), do: Pythonx.Nif.py_long_from_long_long(v)

  @doc """
  Return a new PyLongObject object from a C `unsigned long long`, or `nil` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_unsigned_long_long(non_neg_integer()) :: PyObject.t() | nil
  def from_unsigned_long_long(v) when is_integer(v) and v >= 0, do: Pythonx.Nif.py_long_from_unsigned_long_long(v)

  @doc """
  Return a new PyLongObject object from the integer part of `v`, or `nil` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_double(number()) :: PyObject.t() | nil
  def from_double(v) when is_number(v), do: Pythonx.Nif.py_long_from_double(v)

  @doc """
  Return a new PyLongObject based on the string value in `str`, which is interpreted according to the radix in `base`,
  or `nil` on failure.

  If `base` is 0, `str` is interpreted using the Integer literals definition; in this case, leading zeros in a non-zero
  decimal number raises a `ValueError`.

  If `base` is not 0, it must be between `2` and `36`, inclusive. Leading and trailing whitespace and single underscores
  after a base specifier and between digits are ignored.

  If there are no digits or str is not NULL-terminated following the digits and trailing whitespace, `ValueError` will be raised.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_string(String.t(), 0 | 2..36) :: {PyObject.t(), String.t()} | nil
  def from_string(str, base) when is_binary(str) and base in 0..36, do: Pythonx.Nif.py_long_from_string(str, base)

  @doc """
  Return a C `long` representation of obj.

  If `obj` is not an instance of PyLongObject, first call its `__index__()` method (if present) to convert it to a PyLongObject.

  Returns a `PyErr.t()` with an `OverflowError` if the value of `obj` is out of range for a `long`.
  """
  @doc stable_api: true
  @spec as_long(PyObject.t()) :: integer() | PyErr.t()
  def as_long(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_long(obj)

  @doc """
  Return a C `long` representation of obj.

  If `obj` is not an instance of PyLongObject, first call its `__index__()` method (if present) to convert it to a PyLongObject.

  If the value of `obj` is greater than `LONG_MAX` or less than `LONG_MIN`, returns `{-1, 1}` as `{-1, -1}`, respectively,
  otherwise, the second element is set to `0`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_long_and_overflow(PyObject.t()) :: {result :: integer(), overflow :: -1 | 0 | 1} | PyErr.t()
  def as_long_and_overflow(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_long_and_overflow(obj)

  @doc """
  Return a C `long long` representation of `obj`.

  If `obj` is not an instance of PyLongObject, first call its `__index__()` method (if present) to convert it to a PyLongObject.

  Returns `PyErr.t()` with `OverflowError` if the value of `obj` is out of range for a `long long`.
  """
  @doc stable_api: true
  @spec as_long_long(PyObject.t()) :: integer() | PyErr.t()
  def as_long_long(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_long_long(obj)

  @doc """
  Return a C `long long` representation of `obj`.

  If `obj` is not an instance of PyLongObject, first call its `__index__()` method (if present) to convert it to a PyLongObject.

  If the value of `obj` is greater than `LLONG_MAX` or less than `LLONG_MIN`, , returns `{-1, 1}` as `{-1, -1}`, respectively,

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_long_long_and_overflow(PyObject.t()) :: {result :: integer(), overflow :: -1 | 0 | 1} | PyErr.t()
  def as_long_long_and_overflow(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_long_long_and_overflow(obj)

  @doc """
  Return a C `Py_ssize_t` representation of `pylong`. `pylong` must be an instance of PyLongObject.

  Return `PyErr.t()` with `OverflowError` if the value of `pylong` is out of range for a `Py_ssize_t`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_ssize_t(PyObject.t()) :: integer() | PyErr.t()
  def as_ssize_t(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_ssize_t(obj)

  @doc """
  Return a C `unsigned long` representation of `pylong`. `pylong` must be an instance of PyLongObject.

  Return `PyErr.t()` with `OverflowError` if the value of `pylong` is out of range for a `unsigned long`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_unsigned_long(PyObject.t()) :: integer() | PyErr.t()
  def as_unsigned_long(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_unsigned_long(obj)

  @doc """
  Return a C `size_t` representation of `pylong`. `pylong` must be an instance of PyLongObject.

  Return `PyErr.t()` with `OverflowError` if the value of `pylong` is out of range for a `size_t`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_size_t(PyObject.t()) :: integer() | PyErr.t()
  def as_size_t(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_size_t(obj)

  @doc """
  Return a C `unsigned long long` representation of `pylong`. `pylong` must be an instance of PyLongObject.

  Return `PyErr.t()` with `OverflowError` if the value of `pylong` is out of range for a `unsigned long long`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_unsigned_long_long(PyObject.t()) :: integer() | PyErr.t()
  def as_unsigned_long_long(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_unsigned_long_long(obj)

  @doc """
  Return a C `unsigned long` representation of `pylong`. `pylong` must be an instance of PyLongObject.

  If the value of `obj` is out of range for an `unsigned long`, return the reduction of that value modulo `ULONG_MAX + 1`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_unsigned_long_mask(PyObject.t()) :: integer() | PyErr.t()
  def as_unsigned_long_mask(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_unsigned_long_mask(obj)

  @doc """
  Return a C `unsigned long long` representation of `pylong`. `pylong` must be an instance of PyLongObject.

  If the value of `obj` is out of range for an `unsigned long long`, return the reduction of that value modulo `ULLONG_MAX + 1`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_unsigned_long_long_mask(PyObject.t()) :: integer() | PyErr.t()
  def as_unsigned_long_long_mask(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_unsigned_long_long_mask(obj)

  @doc """
  Return a C `double` representation of `pylong`. `pylong` must be an instance of PyLongObject.

  Return `PyErr.t()` with `OverflowError` if the value of `pylong` is out of range for a `double`.

  If any other exception occurs returns `PyErr.t()`.
  """
  @doc stable_api: true
  @spec as_double(PyObject.t()) :: float() | PyErr.t()
  def as_double(obj) when is_reference(obj), do: Pythonx.Nif.py_long_as_double(obj)

  @doc """
  On success, return a read only named tuple, that holds information about Python’s internal representation of integers.
  See `sys.int_info` for description of individual fields.

  On failure, return `PyErr.t()` with an exception set.
  """
  @doc stable_api: true
  @spec get_info() :: PyObject.t() | PyErr.t()
  def get_info, do: Pythonx.Nif.py_long_get_info()
end

defimpl Pythonx.Codec.Encoder, for: Integer do
  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyLong
  alias Pythonx.C.PyObject, as: CPyObject

  @spec encode(integer()) :: PyObject.t() | PyErr.t()
  def encode(value) when is_integer(value) do
    value
    |> encode_c()
    |> PyObject.from_c_pyobject()
  end

  @spec encode_c(integer()) :: CPyObject.t() | PyErr.t()
  def encode_c(value) when value >= 0 do
    PyLong.from_unsigned_long_long(value)
  end

  def encode_c(value) when value < 0 do
    PyLong.from_long_long(value)
  end
end
