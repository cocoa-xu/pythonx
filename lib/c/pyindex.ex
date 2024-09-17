defmodule Pythonx.C.PyIndex do
  @moduledoc """
  PyIndex objects.
  """

  @doc """
  Returns `true` if `o` is an index integer (has the `nb_index` slot of the `tp_as_number` structure filled in),
  and `false` otherwise.

  This function always succeeds.
  """
  @spec check(PyObject.t()) :: boolean()
  def check(p) when is_reference(p), do: Pythonx.Nif.py_index_check(p)
end
