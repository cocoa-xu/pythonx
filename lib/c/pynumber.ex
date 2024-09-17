defmodule Pythonx.C.PyNumber do
  @moduledoc """
  Number Protocol.

  See more: https://docs.python.org/3/c-api/number.html
  """

  @doc """
  Returns `true` if the object `o` provides numeric protocols, and `false` otherwise.

  This function always succeeds.

  Changed in Python version 3.8: Returns `true` if o is an index integer.
  """
  @spec check(PyObject.t()) :: boolean()
  def check(o) when is_reference(o), do: Pythonx.Nif.py_number_check(o)

  @doc """
  Returns the result of adding `o1` and `o2`, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 + o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec add(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def add(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_add(o1, o2)

  @doc """
  Returns the result of subtracting `o1` and `o2`, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 - o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec subtract(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def subtract(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_subtract(o1, o2)

  @doc """
  Returns the result of multiplying `o1` and `o2`, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 * o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec multiply(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def multiply(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_multiply(o1, o2)

  @doc """
  Returns the result of matrix multiplication on `o1` and `o2`, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 @ o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec matrix_multiply(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def matrix_multiply(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_matrix_multiply(o1, o2)

  @doc """
  Return the floor of `o1` divided by `o2`, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 // o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec floor_divide(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def floor_divide(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_floor_divide(o1, o2)

  @doc """
  Return a reasonable approximation for the mathematical value of `o1` divided by `o2`, or `PyErr.t()` on failure.

  The return value is “approximate” because binary floating-point numbers are approximate; it is not possible to
  represent all real numbers in base two.

  This function can return a floating-point value when passed two integers.

  This is the equivalent of the Python expression `o1 / o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec true_divide(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def true_divide(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_true_divide(o1, o2)

  @doc """
  Returns the remainder of dividing `o1` by `o2`, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 % o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec remainder(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def remainder(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_remainder(o1, o2)

  @doc """
  Take two (non-complex) numbers as arguments and return a pair of numbers consisting of
  their quotient and remainder when using integer division. With mixed operand types, the
  rules for binary arithmetic operators apply.

  For integers, the result is the same as `(a // b, a % b)`.

  For floating-point numbers the result is `(q, a % b)`, where q is usually `math.floor(a / b)`
  but may be `1` less than that.

  In any case `q * b + a % b` is very close to `a`, if `a % b` is non-zero it has the same
  sign as `b`, and `0 <= abs(a % b) < abs(b)`.

  Returns `PyErr.t()` on failure.

  This is the equivalent of the Python expression `divmod(o1, o2)`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec divmod(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def divmod(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_divmod(o1, o2)

  @doc """
  Return `base` to the power `exp`; if `mod` is present, return `base` to the power `exp`, modulo `mod` (computed more efficiently than `pow(base, exp) % mod`).

  The two-argument form `pow(base, exp)` is equivalent to using the power operator: `base**exp`.

  Returns `PyErr.t()` on failure.

  This is the equivalent of the Python expression `pow(o1, o2, o3)`, where `o3` is optional.
  If `o3` is to be ignored, pass `Pythonx.C.py_none/0` in its place.

  The arguments must have numeric types. With mixed operand types, the coercion rules for binary arithmetic operators apply.
  For `int` operands, the result has the same type as the operands (after coercion) unless the second argument is negative;
  in that case, all arguments are converted to `float` and a `float` result is delivered.

  For example, `pow(10, 2)` returns `100`, but `pow(10, -2)` returns `0.01`.

  For a negative base of type `int` or `float` and a non-integral exponent, a complex result is delivered.

  For example, `pow(-9, 0.5)` returns a value close to `3j`. Whereas, for a negative base of type `int` or `float` with an
  integral exponent, a `float` result is delivered.

  For example, `pow(-9, 2.0)` returns `81.0`.

  For `int` operands `base` and `exp`, if `mod` is present, `mod` must also be of integer type and `mod` must be nonzero.
  If `mod` is present and `exp` is negative, `base` must be relatively prime to `mod`. In that case, `pow(inv_base, -exp, mod)`
  is returned, where `inv_base` is an inverse to `base` modulo `mod`.

  Here’s an example of computing an inverse for 38 modulo 97:

  ```python
  >>> pow(38, -1, mod=97)
  23
  >>> 23 * 38 % 97 == 1
  True
  ```

  Changed in Python version 3.8: For `int` operands, the three-argument form of `pow` now allows the second argument to be negative,
  permitting computation of modular inverses.

  Changed in version 3.8: Allow keyword arguments. Formerly, only positional arguments were supported.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec power(PyObject.t(), PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def power(o1, o2, o3) when is_reference(o1) and is_reference(o2) and is_reference(o3),
    do: Pythonx.Nif.py_number_power(o1, o2, o3)

  @doc """
  Returns the negation of `o` on success, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `-o`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec negative(PyObject.t()) :: PyObject.t() | PyErr.t()
  def negative(o) when is_reference(o), do: Pythonx.Nif.py_number_negative(o)

  @doc """
  Returns o on success, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `+o`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec positive(PyObject.t()) :: PyObject.t() | PyErr.t()
  def positive(o) when is_reference(o), do: Pythonx.Nif.py_number_positive(o)

  @doc """
  Returns the absolute value of `o`, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `abs(o)`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec absolute(PyObject.t()) :: PyObject.t() | PyErr.t()
  def absolute(o) when is_reference(o), do: Pythonx.Nif.py_number_absolute(o)

  @doc """
  Returns the bitwise negation of `o` on success, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `~o`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec invert(PyObject.t()) :: PyObject.t() | PyErr.t()
  def invert(o) when is_reference(o), do: Pythonx.Nif.py_number_invert(o)

  @doc """
  Returns the result of left shifting `o1` by `o2` on success, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 << o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec lshift(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def lshift(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_lshift(o1, o2)

  @doc """
  Returns the result of right shifting `o1` by `o2` on success, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 >> o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec rshift(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def rshift(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_rshift(o1, o2)

  @doc """
  Returns the `bitwise and` of `o1` and `o2` on success and `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 & o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec band(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def band(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_and(o1, o2)

  @doc """
  Returns the `bitwise exclusive or` of `o1` and `o2` on success and `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 ^ o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec bxor(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def bxor(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_xor(o1, o2)

  @doc """
  Returns the `bitwise or` of `o1` and `o2` on success and `PyErr.t()` on failure.

  This is the equivalent of the Python expression `o1 | o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec bor(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def bor(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_or(o1, o2)

  @doc """
  Returns the result of adding `o1` and `o2`, or `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 += o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_add(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_add(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_in_place_add(o1, o2)

  @doc """
  Returns the result of subtracting `o1` and `o2`, or `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 -= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_subtract(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_subtract(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_in_place_subtract(o1, o2)

  @doc """
  Returns the result of multiplying `o1` and `o2`, or `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 *= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_multiply(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_multiply(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_in_place_multiply(o1, o2)

  @doc """
  Returns the mathematical floor of dividing `o1` by `o2`, or `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 //= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_floor_divide(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_floor_divide(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_in_place_floor_divide(o1, o2)

  @doc """
  Return a reasonable approximation for the mathematical value of `o1` divided by `o2`, or `PyErr.t()` on failure.

  The return value is `approximate` because binary floating-point numbers are approximate; it is not possible to
  represent all real numbers in base two.

  This function can return a floating-point value when passed two integers.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 /= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_true_divide(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_true_divide(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_in_place_true_divide(o1, o2)

  @doc """
  Returns the remainder of dividing `o1` by `o2`, or `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 %= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_remainder(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_remainder(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_in_place_remainder(o1, o2)

  @doc """
  Similiar to `power/3`, but the operation is done in-place when `o1` supports it.

  Returns `PyErr.t()` on failure. This is the equivalent of the Python statement `o1 **= o2` when `o3`
  is `Pythonx.C.py_none/0`, or an in-place variant of `pow(o1, o2, o3)` otherwise.

  If `o3` is to be ignored, pass `Pythonx.C.py_none/0` in its place.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_power(PyObject.t(), PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_power(o1, o2, o3) when is_reference(o1) and is_reference(o2) and is_reference(o3),
    do: Pythonx.Nif.py_number_in_place_power(o1, o2, o3)

  @doc """
  Returns the result of left shifting `o1` by `o2` on success, or `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 <<= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_lshift(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_lshift(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_in_place_lshift(o1, o2)

  @doc """
  Returns the result of right shifting `o1` by `o2` on success, or `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 >>= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_rshift(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_rshift(o1, o2) when is_reference(o1) and is_reference(o2),
    do: Pythonx.Nif.py_number_in_place_rshift(o1, o2)

  @doc """
  Returns the `bitwise and` of `o1` and `o2` on success and `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 &= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_band(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_band(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_in_place_and(o1, o2)

  @doc """
  Returns the `bitwise exclusive or` of `o1` and `o2` on success and `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 ^= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_bxor(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_bxor(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_in_place_xor(o1, o2)

  @doc """
  Returns the `bitwise or` of `o1` and `o2` on success and `PyErr.t()` on failure.

  The operation is done in-place when `o1` supports it.

  This is the equivalent of the Python statement `o1 |= o2`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec in_place_bor(PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def in_place_bor(o1, o2) when is_reference(o1) and is_reference(o2), do: Pythonx.Nif.py_number_in_place_or(o1, o2)

  @doc """
  Returns the `o` converted to an integer object on success, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `int(o)`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec long(PyObject.t()) :: PyObject.t() | PyErr.t()
  def long(o) when is_reference(o), do: Pythonx.Nif.py_number_long(o)

  @doc """
  Returns the `o` converted to an integer object on success, or `PyErr.t()` on failure.

  This is the equivalent of the Python expression `float(o)`.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec float(PyObject.t()) :: PyObject.t() | PyErr.t()
  def float(o) when is_reference(o), do: Pythonx.Nif.py_number_float(o)

  @doc """
  Returns the `o` converted to a Python `int` on success or `PyErr.t()` with a `TypeError` exception on failure.

  Changed in version 3.10: The result always has exact type int. Previously, the result could have been an
  instance of a subclass of `int`.
  """
  @doc stable_api: true
  @spec index(PyObject.t()) :: PyObject.t() | PyErr.t()
  def index(o) when is_reference(o), do: Pythonx.Nif.py_number_index(o)

  @doc """
  Returns the integer `n` converted to base `base` as a string.

  The base argument must be one of `2`, `8`, `10`, or `16`.

  For base `2`, `8`, or `16`, the returned string is prefixed with a base marker
  of `'0b'`, `'0o'`, or `'0x'`, respectively.

  If `n` is not a Python `int`, it is converted with `PyNumber.index/1` first.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec to_base(PyObject.t(), 2 | 8 | 10 | 16) :: PyObject.t() | PyErr.t()
  def to_base(n, base) when is_reference(n) and base in [2, 8, 10, 16], do: Pythonx.Nif.py_number_to_base(n, base)

  @doc """
  Returns `o` converted to a `Py_ssize_t` value if `o` can be interpreted as an integer.

  If the call fails, a `PyErr.t()` is returned.

  If `o` can be converted to a Python `int` but the attempt to convert to a `Py_ssize_t`
  value would raise an `OverflowError`, then the `exc` argument is the type of exception
  that will be raised (usually `IndexError` or `OverflowError`).

  If `exc` is `nil`, then the exception is cleared and the value is clipped to `PY_SSIZE_T_MIN`
  for a negative integer or `PY_SSIZE_T_MAX` for a positive integer.
  """
  @doc stable_api: true
  @spec as_ssize_t(PyObject.t(), PyObject.t() | nil) :: integer() | PyErr.t()
  def as_ssize_t(o, exc) when is_reference(o) and (exc == nil or is_reference(exc)),
    do: Pythonx.Nif.py_number_as_ssize_t(o, exc)
end
