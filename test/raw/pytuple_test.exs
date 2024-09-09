defmodule Pythonx.C.PyTuple.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyList
  alias Pythonx.C.PyObject
  alias Pythonx.C.PyTuple
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  test "check/1" do
    obj = PyTuple.new(0)
    assert true == PyTuple.check(obj)

    assert false == PyTuple.check(PyObject.py_none())
  end

  test "check_exact/1" do
    obj = PyTuple.new(0)
    assert true == PyTuple.check_exact(obj)

    assert false == PyTuple.check_exact(PyObject.py_none())
  end

  describe "new/1" do
    test "returns reference when len >= 0" do
      obj = PyTuple.new(0)
      assert is_reference(obj)

      obj_type = PyObject.type(obj)
      type_name = PyObject.get_attr_string(obj_type, "__name__")
      type_name = PyUnicode.as_utf8(type_name)
      assert "tuple" == type_name
    end

    test "returns PyErr when len < 0" do
      assert %PyErr{} = PyTuple.new(-1)
    end
  end

  describe "size/1" do
    test "returns the length of the tuple object" do
      obj = PyTuple.new(3)
      assert 3 == PyTuple.size(obj)
    end
  end

  describe "get_item/2" do
    #   test "returns the object at position index in the tuple" do
    #     obj = PyTuple.new(1)
    #     item = PyUnicode.from_string("Elixir")
    #     PyTuple.set_item(obj, 0, item)
    #     assert is_reference(PyTuple.get_item(obj, 0))
    #   end

    test "returns PyErr when index is out of bounds" do
      obj = PyTuple.new(0)
      assert %PyErr{} = PyTuple.get_item(obj, -1)
    end
  end

  describe "get_slice/3" do
    test "returns a slice of the list" do
      list = PyList.new(0)

      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")
      true = PyList.append(list, a)
      true = PyList.append(list, b)
      true = PyList.append(list, c)

      obj = PyList.as_tuple(list)
      slice = PyTuple.get_slice(obj, 1, 3)
      assert is_reference(slice)

      assert 2 == PyTuple.size(slice)

      item_0 = PyTuple.get_item(slice, 0)
      assert is_reference(item_0)
      assert "b" == PyUnicode.as_utf8(item_0)

      item_1 = PyTuple.get_item(slice, 1)
      assert is_reference(item_1)
      assert "c" == PyUnicode.as_utf8(item_1)
    end
  end
end
