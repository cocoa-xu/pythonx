defmodule Pythonx.State do
  @moduledoc false

  @type t :: %__MODULE__{
          globals: map() | Keyword.t(),
          locals: map() | Keyword.t()
        }

  defstruct [:globals, :locals]

  @spec new(Keyword.t()) :: %Pythonx.State{}
  def new(opts \\ []) do
    opts = Keyword.validate!(opts, globals: %{}, locals: %{})

    %__MODULE__{
      globals: opts[:globals],
      locals: opts[:locals]
    }
  end
end
