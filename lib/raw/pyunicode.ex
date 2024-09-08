defmodule Pythonx.Raw.PyUnicode do
  @moduledoc """
  Unicode Objects
  """

  @doc """
  Create a Unicode object from a UTF-8 encoded null-terminated char buffer str.
  """
  @spec from_string(iodata() | list()) :: reference()
  def from_string(string) do
    Pythonx.Nif.py_unicode_from_string(IO.iodata_to_binary(string))
  end

  @doc """
  Returns a reference to a Python Unicode object.
  """
  @spec as_utf8(reference()) :: binary() | :error
  def as_utf8(ref), do: Pythonx.Nif.py_unicode_as_utf8(ref)
end
