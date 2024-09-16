defmodule Pythonx.C.PyRun do
  @moduledoc """
  The functions in this chapter will let you execute Python source code given in a file or a buffer,
  but they will not let you interact in a more detailed way with the interpreter.

  Several of these functions accept a start symbol from the grammar as a parameter.
  The available start symbols are `py_eval_input`, `py_file_input`, and `py_single_input`. These are described following the functions which accept them as parameters.
  """

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyObject

  @doc """
  This is a simplified interface to `PyRun.simple_string_flags/2` below, leaving the flags argument set to `nil`.
  """
  @spec simple_string(String.t()) :: integer()
  def simple_string(command) do
    Pythonx.Nif.py_run_simple_string(command)
  end

  # @doc """
  # This is a simplified interface to `PyRun.simple_string_flags/2` below, leaving the flags argument set to `nil`.
  # """
  # @spec simple_string_flags(command :: String.t(), flags :: PyCompilerFlags.t()) :: integer()
  # def simple_string_flags(command, flags) do
  #   Pythonx.Nif.py_run_simple_string(command, flags)
  # end

  @doc """
  This is a simplified interface to `PyRun.string_flags/5` below, leaving flags set to `nil`.

  Return value: New reference.
  """
  @spec string(String.t(), integer(), PyObject.t(), PyObject.t()) :: PyObject.t() | PyErr.t()
  def string(str, start, globals, locals) do
    Pythonx.Nif.py_run_string(str, start, globals, locals)
  end
end
