defmodule Pythonx.C.PyEval do
  @moduledoc """
  Python Exception
  """

  alias Pythonx.C.PyObject

  @doc """
  Return a dictionary of the builtins in the current execution frame,
  or the interpreter of the thread state if no frame is currently executing.

  Return value: Borrowed reference.
  """
  @doc stable_api: true
  @spec get_builtins() :: PyObject.borrowed()
  def get_builtins, do: Pythonx.Nif.py_eval_get_builtins()

  @doc """
  Return a dictionary of the local variables in the current execution frame, or `nil` if no frame is currently executing.

  Return value: Borrowed reference.
  """
  @doc stable_api: true
  @spec get_locals() :: PyObject.borrowed() | nil
  def get_locals, do: Pythonx.Nif.py_eval_get_locals()

  @doc """
  Return a dictionary of the global variables in the current execution frame, or `nil` if no frame is currently executing.

  Return value: Borrowed reference.
  """
  @doc stable_api: true
  @spec get_globals() :: PyObject.borrowed() | nil
  def get_globals, do: Pythonx.Nif.py_eval_get_globals()

  @doc """
  Return the name of `func` if it is a function, class or instance object, else the name of `funcs` type.
  """
  @doc stable_api: true
  @spec get_func_name(PyObject.t()) :: String.t()
  def get_func_name(func) when is_reference(func), do: Pythonx.Nif.py_eval_get_func_name(func)

  @doc """
  Return a description string, depending on the type of `func`.

  Return values include “()” for functions and methods, “ constructor”, “ instance”, and “ object”.

  Concatenated with the result of `PyEval.get_func_name/1`, the result will be a description of `func`.
  """
  @doc stable_api: true
  @spec get_func_desc(PyObject.t()) :: String.t()
  def get_func_desc(func) when is_reference(func), do: Pythonx.Nif.py_eval_get_func_desc(func)
end
