defmodule Pythonx.C.PyLong.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyLong
  alias Pythonx.C.PyObject
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  test "check/1" do
    obj = PyLong.from_long(1000)
    assert true == PyLong.check(obj)

    assert false == PyLong.check(PyObject.py_none())
  end

  test "check_exact/1" do
    obj = PyLong.from_long(1000)
    assert true == PyLong.check_exact(obj)

    assert false == PyLong.check_exact(PyObject.py_none())
  end

  test "type name" do
    obj = PyLong.from_long(1000)
    obj_type = PyObject.type(obj)
    type_name = PyObject.get_attr_string(obj_type, "__name__")
    type_name = PyUnicode.as_utf8(type_name)
    assert "int" == type_name
  end

  describe "from values" do
    test "returns reference" do
      from_funcs = [
        &PyLong.from_long/1,
        &PyLong.from_unsigned_long/1,
        &PyLong.from_ssize_t/1,
        &PyLong.from_size_t/1,
        &PyLong.from_long_long/1,
        &PyLong.from_unsigned_long_long/1,
        &PyLong.from_double/1
      ]

      for from_func <- from_funcs do
        v = 1000
        obj = from_func.(v)
        assert is_reference(obj)
        assert v == PyLong.as_long(obj)
      end
    end

    test "from_double/1" do
      obj = PyLong.from_double(42.43)
      assert is_reference(obj)
      assert 42 == PyLong.as_long(obj)
    end
  end

  describe "from_string/2" do
    test "when consumes all inputs" do
      {obj, remaining} = PyLong.from_string("1000", 10)
      assert is_reference(obj)
      assert "" == remaining
      assert 1000 == PyLong.as_long(obj)
    end

    test "returns remaining string" do
      {obj, remaining} = PyLong.from_string("1000hello", 10)
      assert is_reference(obj)
      assert "hello" == remaining
      assert 1000 == PyLong.as_long(obj)
    end

    test "returns PyErr.t()" do
      assert %PyErr{} = PyLong.from_string("hello", 10)
    end
  end
end
