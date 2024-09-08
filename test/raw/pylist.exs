defmodule Pythonx.C.PyObject.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyObject
  alias Pythonx.C.PyList
  alias Pythonx.C.PyUnicode
  alias Pythonx.C.PyErr

  setup do
    Pythonx.initialize_once()
  end

  test "check/1" do
    list = PyList.new(0)
    assert true == PyList.check(list)

    assert false == PyList.check(PyObject.py_none())
  end

  test "check_exact/1" do
    list = PyList.new(0)
    assert true == PyList.check_exact(list)

    assert false == PyList.check_exact(PyObject.py_none())
  end

  describe "new/1" do
    test "returns reference when len >= 0" do
      list = PyList.new(0)
      assert is_reference(list)

      obj_type = PyObject.type(list)
      type_name = PyObject.get_attr_string(obj_type, "__name__")
      type_name = PyUnicode.as_utf8(type_name)
      assert "list" == type_name
    end

    test "returns nil when len < 0" do
      assert PyList.new(-1) == nil
    end
  end

  describe "size/1" do
    test "returns the length of the list object" do
      list = PyList.new(3)
      assert 3 == PyList.size(list)
    end
  end

  describe "get_item/2" do
    test "returns the object at position index in the list" do
      list = PyList.new(0)
      item = PyUnicode.from_string("Elixir")
      PyList.append(list, item)
      assert is_reference(PyList.get_item(list, 0))
    end

    test "returns PyErr when index is out of bounds" do
      list = PyList.new(0)
      assert %PyErr{} = PyList.get_item(list, -1)
    end
  end

  describe "insert/3" do
    test "inserts items to the list" do
      list = PyList.new(0)

      item = PyUnicode.from_string("Elixir")
      assert true == PyList.append(list, item)

      item = PyUnicode.from_string("Python")
      assert true == PyList.append(list, item)

      item = PyUnicode.from_string("❤️")
      assert true == PyList.insert(list, 1, item)

      item_0 = PyList.get_item(list, 0)
      assert is_reference(item_0)
      assert "Elixir" == PyUnicode.as_utf8(item_0)

      item_1 = PyList.get_item(list, 1)
      assert is_reference(item_1)
      assert "❤️" == PyUnicode.as_utf8(item_1)

      item_2 = PyList.get_item(list, 2)
      assert is_reference(item_2)
      assert "Python" == PyUnicode.as_utf8(item_2)
    end
  end

  describe "append/2" do
    test "appends items to the list" do
      list = PyList.new(0)

      item = PyUnicode.from_string("Elixir")
      assert true == PyList.append(list, item)

      item = PyUnicode.from_string("Python")
      assert true == PyList.append(list, item)

      item_0 = PyList.get_item(list, 0)
      assert is_reference(item_0)
      assert "Elixir" == PyUnicode.as_utf8(item_0)

      item_1 = PyList.get_item(list, 1)
      assert is_reference(item_1)
      assert "Python" == PyUnicode.as_utf8(item_1)
    end
  end
end
