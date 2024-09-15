defmodule Pythonx.C.PyDict.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyDict
  alias Pythonx.C.PyErr
  alias Pythonx.C.PyList
  alias Pythonx.C.PyObject
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  test "check/1" do
    obj = PyDict.new()
    assert true == PyDict.check(obj)

    assert false == PyDict.check(PyObject.py_none())
  end

  test "check_exact/1" do
    obj = PyDict.new()
    assert true == PyDict.check_exact(obj)

    assert false == PyDict.check_exact(PyObject.py_none())
  end

  describe "new/1" do
    test "returns reference when len >= 0" do
      obj = PyDict.new()
      assert is_reference(obj)

      obj_type = PyObject.type(obj)
      type_name = PyObject.get_attr_string(obj_type, "__name__")
      type_name = PyUnicode.as_utf8(type_name)
      assert "dict" == type_name
    end
  end

  describe "clear/1" do
    test "clears all items" do
      obj = PyDict.new()

      key = PyUnicode.from_string("key")
      value = PyUnicode.from_string("value")
      assert true == PyDict.set_item(obj, key, value)
      assert true == PyDict.contains(obj, key)
      assert "value" == PyUnicode.as_utf8(PyDict.get_item(obj, key))
      assert 1 == PyDict.size(obj)
      assert :ok == PyDict.clear(obj)

      assert 0 == PyDict.size(obj)
      assert false == PyDict.contains(obj, key)
    end
  end

  describe "contains/2" do
    test "returns true if key is in dict, otherwise false" do
      obj = PyDict.new()

      key = PyUnicode.from_string("key")
      value = PyUnicode.from_string("value")
      assert false == PyDict.contains(obj, key)
      assert true == PyDict.set_item(obj, key, value)
      assert true == PyDict.contains(obj, key)
      assert :ok == PyDict.clear(obj)
      refute true == PyDict.contains(obj, key)
    end
  end

  describe "copy/1" do
    test "returns a new dictionary that contains the same key-value pairs as p" do
      obj = PyDict.new()

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")
      true = PyDict.set_item(obj, key1, value1)

      key2 = PyUnicode.from_string("key2")
      value2 = PyUnicode.from_string("value2")
      true = PyDict.set_item(obj, key2, value2)

      assert 2 == PyDict.size(obj)

      copy = PyDict.copy(obj)
      assert is_reference(copy)
      assert 2 == PyDict.size(copy)

      assert true == PyDict.contains(copy, key1)
      assert "value1" == PyUnicode.as_utf8(PyDict.get_item(copy, key1))

      assert true == PyDict.contains(copy, key2)
      assert "value2" == PyUnicode.as_utf8(PyDict.get_item(copy, key2))
    end
  end

  describe "get_item/2 and set_item/3" do
    test "sets the item at key in dict to value" do
      obj = PyDict.new()

      key = PyUnicode.from_string("key")
      value = PyUnicode.from_string("value")
      assert true == PyDict.set_item(obj, key, value)
      assert true == PyDict.contains(obj, key)
      assert "value" == PyUnicode.as_utf8(PyDict.get_item(obj, key))

      key = PyUnicode.from_string("key2")
      assert false == PyDict.contains(obj, key)
      assert true == PyDict.set_item(obj, key, value)
      assert true == PyDict.contains(obj, key)
      assert "value" == PyUnicode.as_utf8(PyDict.get_item(obj, key))
    end
  end

  describe "get_item_string/2 and set_item_string/3" do
    test "sets the item at key in dict to value" do
      obj = PyDict.new()

      value1 = PyUnicode.from_string("value1")
      assert true == PyDict.set_item_string(obj, "key", value1)
      assert "value1" == PyUnicode.as_utf8(PyDict.get_item_string(obj, "key"))

      value2 = PyUnicode.from_string("value2")
      assert true == PyDict.set_item_string(obj, "key2", value2)
      assert "value2" == PyUnicode.as_utf8(PyDict.get_item_string(obj, "key2"))
    end
  end

  describe "get_item_with_error/2" do
    test "returns PyErr when key not in dict" do
      obj = PyDict.new()

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")
      assert true == PyDict.set_item(obj, key1, value1)
      assert "value1" == PyUnicode.as_utf8(PyDict.get_item_with_error(obj, key1))

      key2 = PyUnicode.from_string("key2")
      assert %PyErr{} = PyDict.get_item_with_error(obj, key2)
    end
  end

  describe "del_item/2" do
    test "deletes the item at key in dict" do
      obj = PyDict.new()

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")
      assert true == PyDict.set_item(obj, key1, value1)
      assert true == PyDict.contains(obj, key1)
      assert "value1" == PyUnicode.as_utf8(PyDict.get_item(obj, key1))

      key2 = PyUnicode.from_string("key2")
      value2 = PyUnicode.from_string("value2")
      assert false == PyDict.contains(obj, key2)
      assert true == PyDict.set_item(obj, key2, value2)
      assert true == PyDict.contains(obj, key2)
      assert "value2" == PyUnicode.as_utf8(PyDict.get_item(obj, key2))
      assert 2 == PyDict.size(obj)

      assert :ok == PyDict.del_item(obj, key1)
      assert 1 == PyDict.size(obj)
      assert false == PyDict.contains(obj, key1)
      assert %PyErr{} = PyDict.get_item_with_error(obj, key1)
      assert true == PyDict.contains(obj, key2)
      assert "value2" == PyUnicode.as_utf8(PyDict.get_item(obj, key2))

      assert :ok == PyDict.del_item(obj, key2)
      assert 0 == PyDict.size(obj)
      assert false == PyDict.contains(obj, key2)
      assert %PyErr{} = PyDict.get_item_with_error(obj, key2)
    end
  end

  describe "del_item_string/3" do
    test "deletes the item at key in dict" do
      obj = PyDict.new()

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")
      assert true == PyDict.set_item(obj, key1, value1)
      assert true == PyDict.contains(obj, key1)
      assert "value1" == PyUnicode.as_utf8(PyDict.get_item(obj, key1))

      key2 = PyUnicode.from_string("key2")
      value2 = PyUnicode.from_string("value2")
      assert false == PyDict.contains(obj, key2)
      assert true == PyDict.set_item(obj, key2, value2)
      assert true == PyDict.contains(obj, key2)
      assert "value2" == PyUnicode.as_utf8(PyDict.get_item(obj, key2))
      assert 2 == PyDict.size(obj)

      assert :ok == PyDict.del_item_string(obj, "key1")
      assert 1 == PyDict.size(obj)
      assert false == PyDict.contains(obj, key1)
      assert %PyErr{} = PyDict.get_item_with_error(obj, key1)
      assert true == PyDict.contains(obj, key2)
      assert "value2" == PyUnicode.as_utf8(PyDict.get_item(obj, key2))

      assert :ok == PyDict.del_item_string(obj, "key2")
      assert 0 == PyDict.size(obj)
      assert false == PyDict.contains(obj, key2)
      assert %PyErr{} = PyDict.get_item_with_error(obj, key2)
    end
  end

  describe "set_default/3" do
    test "inserts with value defaultobj and defaultobj is returned" do
      obj = PyDict.new()

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")

      key2 = PyUnicode.from_string("key2")
      default_value = PyUnicode.from_string("default_value")

      true = PyDict.set_item(obj, key1, value1)
      assert 1 == PyDict.size(obj)

      assert true == PyDict.contains(obj, key1)
      assert "value1" == PyUnicode.as_utf8(PyDict.get_item(obj, key1))
      assert false == PyDict.contains(obj, key2)

      value = PyDict.set_default(obj, key2, default_value)
      assert true == PyDict.contains(obj, key2)
      assert 2 == PyDict.size(obj)
      assert is_reference(value)
      assert "default_value" == PyUnicode.as_utf8(value)
    end
  end

  describe "items/1" do
    test "returns a PyListObject containing all the items from the dictionary" do
      obj = PyDict.new()

      items = PyDict.items(obj)
      assert is_reference(items)
      assert 0 == PyList.size(items)

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")
      assert true == PyDict.set_item(obj, key1, value1)
      items = PyDict.items(obj)
      assert is_reference(items)
      assert 1 == PyList.size(items)

      key2 = PyUnicode.from_string("key2")
      value2 = PyUnicode.from_string("value2")
      assert true == PyDict.set_item(obj, key2, value2)
      items = PyDict.items(obj)
      assert is_reference(items)
      assert 2 == PyList.size(items)
    end
  end

  describe "keys/1" do
    test "returns a PyListObject containing all the keys from the dictionary" do
      obj = PyDict.new()

      keys = PyDict.keys(obj)
      assert is_reference(keys)
      assert 0 == PyList.size(keys)

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")
      assert true == PyDict.set_item(obj, key1, value1)
      keys = PyDict.keys(obj)
      assert is_reference(keys)
      assert 1 == PyList.size(keys)

      key = PyList.get_item(keys, 0)
      assert is_reference(key)
      assert "key1" == PyUnicode.as_utf8(key)
    end
  end

  describe "values/1" do
    test "returns a PyListObject containing all the values from the dictionary" do
      obj = PyDict.new()

      values = PyDict.values(obj)
      assert is_reference(values)
      assert 0 == PyList.size(values)

      key1 = PyUnicode.from_string("key1")
      value1 = PyUnicode.from_string("value1")
      assert true == PyDict.set_item(obj, key1, value1)
      values = PyDict.values(obj)
      assert is_reference(values)
      assert 1 == PyList.size(values)

      value = PyList.get_item(values, 0)
      assert is_reference(value)
      assert "value1" == PyUnicode.as_utf8(value)
    end
  end

  describe "size/1" do
    test "returns the length of the list object" do
      obj = PyDict.new()
      assert 0 == PyDict.size(obj)
    end
  end
end
