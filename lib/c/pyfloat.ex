defmodule Pythonx.C.PyFloat do
  @moduledoc """
  This subtype of PyObject represents a Python floating-point object.
  """

  @doc """
  Return `true` if its argument is a PyFloatObject or a subtype of PyFloatObject.

  This function always succeeds.
  """
  @spec check(PyObject.t()) :: boolean()
  def check(p) when is_reference(p), do: Pythonx.Nif.py_float_check(p)

  @doc """
  Return `true` if its argument is a PyFloatObject, but not a subtype of PyFloatObject. This function always succeeds.

  This function always succeeds.
  """
  @spec check_exact(PyObject.t()) :: boolean()
  def check_exact(p) when is_reference(p), do: Pythonx.Nif.py_float_check_exact(p)

  @doc """
  Create a PyFloatObject object based on the string value in `str`, or `PyErr.t()` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_string(PyObject.t()) :: PyObject.t() | PyErr.t()
  def from_string(str) when is_reference(str), do: Pythonx.Nif.py_float_from_string(str)

  @doc """
  Create a PyFloatObject object from `v`, or `PyErr.t()` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec from_double(number()) :: PyObject.t() | PyErr.t()
  def from_double(v) when is_number(v), do: Pythonx.Nif.py_float_from_double(v)

  @doc """
  Return a C double representation of the contents of pyfloat. If pyfloat is not a Python floating-point object but has a __float__() method, this method will first be called to convert pyfloat into a float. If __float__() is not defined then it falls back to __index__(). This method returns -1.0 upon failure, so one should call PyErr_Occurred() to check for errors.
  """
  @doc stable_api: true
  @spec as_double(PyObject.t()) :: float() | PyErr.t()
  def as_double(v) when is_reference(v), do: Pythonx.Nif.py_float_as_double(v)

  @doc """
  Return a new PyLongObject object from a C `size_t`, or `nil` on failure.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec get_info() :: PyObject.t() | PyErr.t()
  def get_info, do: Pythonx.Nif.py_float_get_info()

  @doc """
  Return the maximum representable finite float `DBL_MAX` as C `double`.
  """
  @doc stable_api: true
  @spec get_max() :: float()
  def get_max, do: Pythonx.Nif.py_float_get_max()

  @doc """
  Return the minimum normalized positive float `DBL_MIN` as C `double`.
  """
  @doc stable_api: true
  @spec get_min() :: float()
  def get_min, do: Pythonx.Nif.py_float_get_min()
end
