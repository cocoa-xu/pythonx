defmodule Pythonx.Beam.State do
  @moduledoc false
  alias Pythonx.Beam
  alias Pythonx.Beam.PyObject

  @type t :: %__MODULE__{
          globals: PyObject.t(),
          locals: PyObject.t()
        }

  defstruct [:globals, :locals]

  @spec new(Keyword.t()) :: t()
  def new(opts \\ []) do
    opts = Keyword.validate!(opts, globals: %{}, locals: %{})

    %__MODULE__{
      globals: Beam.encode(opts[:globals]),
      locals: Beam.encode(opts[:locals])
    }
  end
end
