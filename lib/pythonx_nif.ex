defmodule Pythonx.Nif do
  @moduledoc false

  @on_load :load_nif
  def load_nif do
    nif_file = ~c"#{:code.priv_dir(:pythonx)}/pythonx"

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> IO.puts("Failed to load nif: #{inspect(reason)}")
    end
  end

  def initialize1(_python_home), do: :erlang.nif_error(:not_loaded)
  def initialize2(_python_home, _minor_version), do: :erlang.nif_error(:not_loaded)
  def eval(_string, _vars, _locals, _globals), do: :erlang.nif_error(:not_loaded)
  def finalize, do: :erlang.nif_error(:not_loaded)
end
