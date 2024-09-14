defmodule Pythonx.C.PyObject.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyObject
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  test "py_none/0" do
    py_none = PyObject.py_none()
    assert is_reference(py_none)

    obj_type = PyObject.type(py_none)
    type_name = PyObject.get_attr_string(obj_type, "__name__")
    type_name = PyUnicode.as_utf8(type_name)
    assert "NoneType" == type_name
  end

  test "py_true/0" do
    py_true = PyObject.py_true()
    assert is_reference(py_true)
    assert true == PyObject.is_true(py_true)
    assert false == PyObject.not(py_true)

    obj_type = PyObject.type(py_true)
    type_name = PyObject.get_attr_string(obj_type, "__name__")
    type_name = PyUnicode.as_utf8(type_name)
    assert "bool" == type_name
  end

  test "py_false/0" do
    py_false = PyObject.py_false()
    assert is_reference(py_false)
    assert false == PyObject.is_true(py_false)
    assert true == PyObject.not(py_false)

    obj_type = PyObject.type(py_false)
    type_name = PyObject.get_attr_string(obj_type, "__name__")
    type_name = PyUnicode.as_utf8(type_name)
    assert "bool" == type_name
  end

  test "py_incref/1 and py_decref/" do
    py_none = PyObject.py_none()
    assert is_reference(py_none)

    py_none = PyObject.incref(py_none)
    assert is_reference(py_none)
    py_none = PyObject.decref(py_none)
    assert is_reference(py_none)
  end

  describe "attr" do
    test "has_attr/2" do
      obj_type = PyObject.type(PyObject.py_none())
      assert true == PyObject.has_attr(obj_type, PyUnicode.from_string("__name__"))
      assert false == PyObject.has_attr(obj_type, PyUnicode.from_string("foo"))
    end

    test "has_attr_string/2" do
      obj_type = PyObject.type(PyObject.py_none())
      assert true == PyObject.has_attr_string(obj_type, "__name__")
      assert false == PyObject.has_attr_string(obj_type, "foo")
    end

    test "get_attr/2" do
      type_name =
        PyObject.py_none()
        |> PyObject.type()
        |> PyObject.get_attr(PyUnicode.from_string("__name__"))
        |> PyUnicode.as_utf8()

      assert "NoneType" == type_name
    end

    test "get_attr/2 when attr doesn't exists" do
      type_name =
        PyObject.py_none()
        |> PyObject.type()
        |> PyObject.get_attr(PyUnicode.from_string("foo"))

      assert nil == type_name
    end

    test "get_attr_string/2" do
      type_name =
        PyObject.py_none()
        |> PyObject.type()
        |> PyObject.get_attr_string("__name__")
        |> PyUnicode.as_utf8()

      assert "NoneType" == type_name
    end

    test "get_attr_string/2 when attr doesn't exists" do
      type_name =
        PyObject.py_none()
        |> PyObject.type()
        |> PyObject.get_attr_string("foo")

      assert nil == type_name
    end

    test "generic_get_attr/2" do
      type_name =
        PyObject.py_none()
        |> PyObject.type()
        |> PyObject.generic_get_attr(PyUnicode.from_string("__name__"))
        |> PyUnicode.as_utf8()

      assert "NoneType" == type_name
    end

    test "generic_get_attr/2 when attr doesn't exists" do
      type_name =
        PyObject.py_none()
        |> PyObject.type()
        |> PyObject.generic_get_attr(PyUnicode.from_string("foo"))

      assert %PyErr{} = type_name
    end
  end

  describe "is_true/1" do
    test "returns true when the object is considered to be true" do
      py_true = PyObject.py_true()
      assert true == PyObject.is_true(py_true)
    end

    test "returns false when the object is considered to be true" do
      py_false = PyObject.py_false()
      assert false == PyObject.is_true(py_false)
    end
  end

  describe "not/1" do
    test "returns true when the object is considered to be true" do
      py_true = PyObject.py_true()
      assert false == PyObject.not(py_true)
    end

    test "returns false when the object is considered to be true" do
      py_false = PyObject.py_false()
      assert true == PyObject.not(py_false)
    end
  end

  describe "type/1" do
    test "returns true when the object is considered to be true" do
      py_true = PyObject.py_true()
      true_type = PyObject.type(py_true)
      assert is_reference(true_type)

      type_name = PyObject.get_attr_string(true_type, "__name__")
      assert is_reference(type_name)

      type_name = PyUnicode.as_utf8(type_name)
      assert "bool" == type_name

      name_attr = PyUnicode.from_string("__name__")
      type_name = PyObject.get_attr(true_type, name_attr)
      assert is_reference(type_name)

      type_name = PyUnicode.as_utf8(type_name)
      assert "bool" == type_name
    end
  end

  test "repr/1" do
    py_true = PyObject.py_true()
    repr = PyObject.repr(py_true)
    assert is_reference(repr)

    repr = PyUnicode.as_utf8(repr)
    assert "True" == repr
  end

  test "ascii/1" do
    ascii = PyObject.ascii(PyObject.py_none())
    assert is_reference(ascii)

    ascii = PyUnicode.as_utf8(ascii)
    assert "None" == ascii
  end

  test "str/1" do
    str = PyObject.str(PyObject.py_false())
    assert is_reference(str)

    str = PyUnicode.as_utf8(str)
    assert "False" == str
  end
end
