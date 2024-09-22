defmodule Pythonx.C.PyFrozenSet do
  @moduledoc false

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyObject

  @doc """
  Return `true` if `p` is a `frozenset` object, or an instance of a subtype

  This function always succeeds.
  """
  @doc stable_api: true
  @spec check(PyObject.t()) :: boolean()
  def check(p), do: Pythonx.Nif.py_frozenset_check(p)

  @doc """
  Return true if `p` is a `frozenset` object but not an instance of a subtype.

  This function always succeeds.
  """
  @doc stable_api: true
  @spec check_exact(PyObject.t()) :: boolean()
  def check_exact(p), do: Pythonx.Nif.py_frozenset_check_exact(p)

  @doc """
  Return a new `frozenset` containing objects returned by the `iterable`.

  The `iterable` may be `nil` to create a new empty `frozenset`.

  Return the new set on success or `PyErr.t()` on failure.

  Return `PyErr.t()` with `TypeError` if iterable is not actually iterable.

  Return value: New reference.
  """
  @doc stable_api: true
  @spec new(PyObject.t() | nil) :: PyObject.t() | PyErr.t()
  def new(iterable) when is_reference(iterable) or is_nil(iterable), do: Pythonx.Nif.py_frozenset_new(iterable)
end
