defprotocol Pythonx.Codec.Decoder do
  @doc """
  Decode a Python object to BEAM values.
  """
  @spec decode(value :: any()) :: any()
  def decode(value)
end

defimpl Pythonx.Codec.Decoder, for: Any do
  def decode(_) do
    raise RuntimeError, "Not implemented"
  end
end
