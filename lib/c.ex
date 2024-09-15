defmodule Pythonx.C do
  @moduledoc false

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
end
