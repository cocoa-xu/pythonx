defmodule Pythonx.C do
  @moduledoc """
  Python C API.
  """

  @doc """
  Flag to be used with multiple functions that print the object (like `PyObject.print/1` and `PyFile.write_object`).

  If passed, these function would use the `str()` of the object instead of the `repr()`.
  """
  @spec py_print_raw :: integer()
  def py_print_raw, do: Pythonx.Nif.py_print_raw()

  @doc """
  The start symbol from the Python grammar for isolated expressions; for use with Py_CompileString().
  """
  @spec py_eval_input :: integer()
  def py_eval_input, do: Pythonx.Nif.py_eval_input()

  @doc """
  The start symbol from the Python grammar for sequences of statements as read from a file or other source;
  for use with Py_CompileString().

  This is the symbol to use when compiling arbitrarily long Python source code.
  """
  @spec py_file_input :: integer()
  def py_file_input, do: Pythonx.Nif.py_file_input()

  @doc """
  The start symbol from the Python grammar for a single statement; for use with Py_CompileString().

  This is the symbol used for the interactive interpreter loop.
  """
  @spec py_single_input :: integer()
  def py_single_input, do: Pythonx.Nif.py_single_input()

  defdelegate py_none(), to: Pythonx.C.PyObject
  defdelegate py_true(), to: Pythonx.C.PyObject
  defdelegate py_false(), to: Pythonx.C.PyObject
end
