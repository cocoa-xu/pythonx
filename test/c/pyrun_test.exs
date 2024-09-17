defmodule Pythonx.C.PyRun.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C
  alias Pythonx.C.PyDict
  alias Pythonx.C.PyLong
  alias Pythonx.C.PyRun
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  describe "simple_string/1" do
    @tag :c_pyrun
    test "returns 0 when succeeded" do
      return = PyRun.simple_string("1 + 2")
      assert is_integer(return)
      assert 0 == return
    end

    @tag :c_pyrun
    test "returns non-zero when failed" do
      return = PyRun.simple_string("b + 2")
      assert is_integer(return)
      assert -1 == return
    end
  end

  @tag :c_pyrun
  test "string/4" do
    globals = PyDict.new()
    locals = PyDict.new()
    a = PyLong.from_long(1)
    b = PyLong.from_long(2)
    PyDict.set_item_string(locals, "a", a)
    PyDict.set_item_string(locals, "b", b)
    PyRun.string("c = a + b", C.py_file_input(), globals, locals)
    c = PyUnicode.from_string("c")
    val_c = PyDict.get_item_with_error(locals, c)
    assert 3 == PyLong.as_long(val_c)
  end
end
