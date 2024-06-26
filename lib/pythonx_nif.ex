defmodule Pythonx.Nif do
  @moduledoc false

  @on_load :load_nif
  def load_nif do
    nif_file = ~c"#{:code.priv_dir(:pythonx)}/pythonx"
    python_home = "#{:code.priv_dir(:pythonx)}/python3"
    preserved = System.get_env("PYTHONHOME")
    System.put_env("PYTHONHOME", python_home)

    result =
      case :erlang.load_nif(nif_file, 0) do
        :ok -> :ok
        {:error, {:reload, _}} -> :ok
        {:error, reason} -> IO.puts("Failed to load nif: #{reason}")
      end

    if preserved do
      System.put_env("PYTHONHOME", preserved)
    end

    result
  end

  def eval(_string, _vars, _locals, _globals), do: :erlang.nif_error(:not_loaded)
end
