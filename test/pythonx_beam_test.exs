defmodule Pythonx.Beam.Test do
  use ExUnit.Case, async: false

  setup do
    Pythonx.initialize_once()
  end

  describe "encoding" do
    alias Pythonx.Beam.PyObject
    alias Pythonx.C.PyFloat

    test "encode/1" do
      encoded = Pythonx.Beam.encode(42.42)
      assert "float" == PyObject.type(encoded)
      assert_in_delta 42.42, PyFloat.as_double(encoded.ref), 0.0001
    end
  end
end
