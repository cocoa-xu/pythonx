defmodule Pythonx.C.PyRun do
  @moduledoc """
  The functions in this chapter will let you execute Python source code given in a file or a buffer,
  but they will not let you interact in a more detailed way with the interpreter.

  Several of these functions accept a start symbol from the grammar as a parameter.
  The available start symbols are `py_eval_input`, `py_file_input`, and `py_single_input`. These are described following the functions which accept them as parameters.
  """

  @doc """
  This is a simplified interface to `PyRun.string_flags/5` below, leaving flags set to `nil`.

  Return value: New reference.
  """
  def string(str, start, globals, locals) do
    Pythonx.Nif.py_run_string(str, start, globals, locals)
  end
end
