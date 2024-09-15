defmodule Pythonx.C.PyCompilerFlags do
  @moduledoc """
  Python compiler flags.
  """

  @type t :: %__MODULE__{}

  defstruct [
    :cf_flags,
    :cf_feature_version,
  ]

  @doc """
  The compiler flags for the Python compiler.
  """
  @spec new :: t()
  def new do
    %__MODULE__{
      cf_flags: 0,
      cf_feature_version: 8,
    }
  end

  @doc """
  The compiler flags for the Python compiler.
  """
  @spec new(cf_flags :: integer(), cf_feature_version :: integer()) :: t()
  def new(cf_flags, cf_feature_version) do
    %__MODULE__{
      cf_flags: cf_flags,
      cf_feature_version: cf_feature_version,
    }
  end
end
