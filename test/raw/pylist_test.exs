defmodule Pythonx.C.PyList.Test do
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

    test "returns PyErr when len < 0" do
      assert %PyErr{} = PyList.new(-1)
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

  describe "get_slice/3" do
    test "returns a slice of the list" do
      list = PyList.new(0)

      item = PyUnicode.from_string("Elixir")
      assert true == PyList.append(list, item)

      item = PyUnicode.from_string("❤️")
      assert true == PyList.append(list, item)

      item = PyUnicode.from_string("Python")
      assert true == PyList.append(list, item)

      slice = PyList.get_slice(list, 1, 3)
      assert is_reference(slice)

      assert 2 == PyList.size(slice)

      item_0 = PyList.get_item(slice, 0)
      assert is_reference(item_0)
      assert "❤️" == PyUnicode.as_utf8(item_0)

      item_1 = PyList.get_item(slice, 1)
      assert is_reference(item_1)
      assert "Python" == PyUnicode.as_utf8(item_1)
    end

    test "returns a slice when start is out of bounds" do
      list = PyList.new(0)

      item = PyUnicode.from_string("Elixir")
      true = PyList.append(list, item)

      slice = PyList.get_slice(list, -2, 1)
      assert is_reference(slice)

      assert 1 == PyList.size(slice)

      item_0 = PyList.get_item(slice, 0)
      assert is_reference(item_0)
      assert "Elixir" == PyUnicode.as_utf8(item_0)
    end

    test "returns a slice when end is out of bounds" do
      list = PyList.new(0)
      item = PyUnicode.from_string("Elixir")
      true = PyList.append(list, item)

      slice = PyList.get_slice(list, 0, 3)
      assert is_reference(slice)

      assert 1 == PyList.size(slice)

      item_0 = PyList.get_item(slice, 0)
      assert is_reference(item_0)
      assert "Elixir" == PyUnicode.as_utf8(item_0)
    end
  end

  describe "set_slice/4" do
    test "sets a slice of the list" do
      # list = ["Elixir", "Python", "❤️"]
      # slice = ["❤️", "Python"]
      # list[1:3] = slice

      list = PyList.new(0)

      elixir = PyUnicode.from_string("Elixir")
      python = PyUnicode.from_string("Python")
      heart = PyUnicode.from_string("❤️")

      true = PyList.append(list, elixir)
      true = PyList.append(list, python)
      true = PyList.append(list, heart)
      assert 3 == PyList.size(list)

      slice = PyList.new(0)
      true = PyList.append(slice, heart)
      true = PyList.append(slice, python)
      assert 2 == PyList.size(slice)

      assert true == PyList.set_slice(list, 1, 3, slice)
      assert 3 == PyList.size(list)

      item_0 = PyList.get_item(list, 0)
      assert "Elixir" == PyUnicode.as_utf8(item_0)

      item_1 = PyList.get_item(list, 1)
      assert "❤️" == PyUnicode.as_utf8(item_1)

      item_2 = PyList.get_item(list, 2)
      assert "Python" == PyUnicode.as_utf8(item_2)
    end

    test "slice deletion when `itemlist` is nil" do
      # list = ["Elixir", "Python", "❤️"]
      # list[1:3] = []

      list = PyList.new(0)

      elixir = PyUnicode.from_string("Elixir")
      python = PyUnicode.from_string("Python")
      heart = PyUnicode.from_string("❤️")

      true = PyList.append(list, elixir)
      true = PyList.append(list, python)
      true = PyList.append(list, heart)
      assert 3 == PyList.size(list)

      assert true == PyList.set_slice(list, 1, 3, nil)
      assert 1 == PyList.size(list)

      item_0 = PyList.get_item(list, 0)
      assert "Elixir" == PyUnicode.as_utf8(item_0)
    end
  end

  describe "sort/1" do
    test "sorts the list" do
      list = PyList.new(0)

      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")

      true = PyList.append(list, a)
      true = PyList.append(list, c)
      true = PyList.append(list, b)
      assert 3 == PyList.size(list)

      assert true == PyList.sort(list)
      assert 3 == PyList.size(list)

      item_0 = PyList.get_item(list, 0)
      assert "a" == PyUnicode.as_utf8(item_0)

      item_1 = PyList.get_item(list, 1)
      assert "b" == PyUnicode.as_utf8(item_1)

      item_2 = PyList.get_item(list, 2)
      assert "c" == PyUnicode.as_utf8(item_2)
    end
  end

  describe "reverse/1" do
    test "reverses the list" do
      list = PyList.new(0)

      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")

      true = PyList.append(list, a)
      true = PyList.append(list, b)
      true = PyList.append(list, c)
      assert 3 == PyList.size(list)

      assert true == PyList.reverse(list)
      assert 3 == PyList.size(list)

      item_0 = PyList.get_item(list, 0)
      assert "c" == PyUnicode.as_utf8(item_0)

      item_1 = PyList.get_item(list, 1)
      assert "b" == PyUnicode.as_utf8(item_1)

      item_2 = PyList.get_item(list, 2)
      assert "a" == PyUnicode.as_utf8(item_2)
    end
  end

  describe "as_tuple/1" do
    test "returns a tuple object containing the contents of the list" do
      list = PyList.new(0)

      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")

      true = PyList.append(list, a)
      true = PyList.append(list, b)
      true = PyList.append(list, c)
      assert 3 == PyList.size(list)

      tuple = PyList.as_tuple(list)
      assert is_reference(tuple)
      assert 3 == PyTuple.size(tuple)

      item_0 = PyTuple.get_item(tuple, 0)
      assert "a" == PyUnicode.as_utf8(item_0)

      item_1 = PyTuple.get_item(tuple, 1)
      assert "b" == PyUnicode.as_utf8(item_1)

      item_2 = PyTuple.get_item(tuple, 2)
      assert "c" == PyUnicode.as_utf8(item_2)
    end
  end
end
