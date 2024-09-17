defmodule Pythonx.C.PyFloat.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyFloat
  alias Pythonx.C.PyObject
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  test "check/1" do
    obj = PyFloat.from_double(4.2)
    assert true == PyFloat.check(obj)

    assert false == PyFloat.check(PyObject.py_none())
  end

  test "check_exact/1" do
    obj = PyFloat.from_double(4.2)
    assert true == PyFloat.check_exact(obj)

    assert false == PyFloat.check_exact(PyObject.py_none())
  end

  test "type name" do
    obj = PyFloat.from_double(4.2)
    obj_type = PyObject.type(obj)
    type_name = PyObject.get_attr_string(obj_type, "__name__")
    type_name = PyUnicode.as_utf8(type_name)
    assert "float" == type_name
  end

  describe "from_string/1" do
    test "returns reference on success" do
      val = PyFloat.from_string(PyUnicode.from_string("4.2"))
      assert is_reference(val)
      assert 4.2 == PyFloat.as_double(val)
    end

    test "returns PyErr.t on failure" do
      assert %PyErr{} = PyFloat.from_string(PyUnicode.from_string("hello"))
    end
  end

  describe "from_double/1" do
    test "returns reference on success" do
      val = PyFloat.from_double(4.2)
      assert is_reference(val)
      assert 4.2 == PyFloat.as_double(val)
    end
  end

  describe "as_double/1" do
    test "returns value from a pyfloat" do
      val = PyFloat.from_double(4.2)
      assert is_reference(val)
      assert 4.2 == PyFloat.as_double(val)
    end
  end

  describe "get_info/0" do
    @tag :flaky
    test "returns a reference" do
      info = PyFloat.get_info()
      assert is_reference(info)
    end
  end

  describe "get max and min" do
    test "max" do
      val = PyFloat.get_max()
      assert is_float(val)
    end

    test "min" do
      val = PyFloat.get_min()
      assert is_float(val)
    end
  end
end
