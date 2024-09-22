defmodule Pythonx.C.PyAnySet do
  @moduledoc false

  alias Pythonx.C.PyObject

  @doc """
  Return `true` if `p` is a `set` object, a `frozenset` object, or an instance of a subtype

  This function always succeeds.
  """
  @doc stable_api: true
  @spec check(PyObject.t()) :: boolean()
  def check(p), do: Pythonx.Nif.py_anyset_check(p)

  @doc """
  Return true if `p` is a `frozenset` object but not an instance of a subtype.

  This function always succeeds.
  """
  @doc stable_api: true
  @spec check_exact(PyObject.t()) :: boolean()
  def check_exact(p), do: Pythonx.Nif.py_anyset_check_exact(p)
end
