defmodule Pythonx.Raw.PyUnicode.Test do
  use ExUnit.Case, async: false

  alias Pythonx.Raw.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  describe "from_string/1" do
    test "only allows iodata" do
      str = PyUnicode.from_string("Elixir")
      assert is_reference(str)

      str = PyUnicode.from_string(["Elixir"])
      assert is_reference(str)

      str = PyUnicode.from_string(["Elixir", "Python"])
      assert is_reference(str)

      str = PyUnicode.from_string(["Elixir", 20, "Python"])
      assert is_reference(str)
    end

    test "raises when non-iodata terms passed" do
      assert_raise ArgumentError, fn ->
        PyUnicode.from_string(%{})
      end
    end
  end

  describe "as_utf8/1" do
    test "returns correct data from a PyUnicode object" do
      str = PyUnicode.from_string("Elixir")
      assert "Elixir" == PyUnicode.as_utf8(str)

      str = PyUnicode.from_string(["Elixir"])
      assert "Elixir" == PyUnicode.as_utf8(str)

      str = PyUnicode.from_string(["Elixir", "Python"])
      assert "ElixirPython" == PyUnicode.as_utf8(str)

      str = PyUnicode.from_string(["Elixir", 32, "Python"])
      assert "Elixir Python" == PyUnicode.as_utf8(str)

      str = PyUnicode.from_string([~c"Elixir", 32, "Python"])
      assert "Elixir Python" == PyUnicode.as_utf8(str)
    end

    test "raises when invalid arguments passed" do
      assert_raise ArgumentError, fn ->
        PyUnicode.as_utf8(%{})
      end
    end
  end

  describe "round trip" do
    test "can init a unicode object with elixir strings" do
      str = PyUnicode.from_string("Elixir")
      assert "Elixir" == PyUnicode.as_utf8(str)

      str = PyUnicode.from_string("Python")
      assert "Python" == PyUnicode.as_utf8(str)
    end

    test "can init a unicode object with Erlang strings" do
      str = PyUnicode.from_string(~c"Elixir")
      assert "Elixir" == PyUnicode.as_utf8(str)

      str = PyUnicode.from_string(~c"Python")
      assert "Python" == PyUnicode.as_utf8(str)
    end

    test "can init a unicode object with iodata" do
      str = PyUnicode.from_string(["Elixir", "Python"])
      assert "ElixirPython" == PyUnicode.as_utf8(str)

      str = PyUnicode.from_string(["Python", "Elixir", 65, 66])
      assert "PythonElixirAB" == PyUnicode.as_utf8(str)
    end
  end
end
