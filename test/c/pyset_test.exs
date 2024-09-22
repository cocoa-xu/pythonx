defmodule Pythonx.C.PySet.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyList
  alias Pythonx.C.PyObject
  alias Pythonx.C.PySet
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  test "check/1" do
    obj = PySet.new(nil)
    assert true == PySet.check(obj)

    assert false == PySet.check(PyObject.py_none())
  end

  describe "new/1" do
    test "returns reference with nil" do
      obj = PySet.new(nil)
      assert is_reference(obj)

      assert 0 == PySet.size(obj)
    end

    test "returns reference with an iterable object" do
      list = PyList.new(0)

      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")

      true = PyList.append(list, a)
      true = PyList.append(list, c)
      true = PyList.append(list, b)
      assert 3 == PyList.size(list)

      obj = PySet.new(list)
      assert is_reference(obj)

      assert 3 == PySet.size(obj)
    end
  end

  describe "size/1" do
    test "returns 0 for any empty sets" do
      obj = PySet.new(nil)
      assert 0 == PySet.size(obj)
    end

    test "returns the number of elements in the set" do
      list = PyList.new(0)

      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")

      true = PyList.append(list, a)
      true = PyList.append(list, c)
      true = PyList.append(list, b)
      assert 3 == PyList.size(list)

      obj = PySet.new(list)
      assert 3 == PySet.size(obj)
    end
  end

  describe "contains/2" do
    test "returns true if found" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")
      true = PySet.add(obj, a)

      assert true == PySet.contains(obj, a)
    end

    test "returns false if not found" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      true = PySet.add(obj, a)

      assert false == PySet.contains(obj, b)
    end
  end

  describe "add/2" do
    test "adds a key to a set instance" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")

      true = PySet.add(obj, a)
      assert true == PySet.contains(obj, a)
      assert 1 == PySet.size(obj)

      true = PySet.add(obj, b)
      assert true == PySet.contains(obj, b)
      assert 2 == PySet.size(obj)
    end

    test "only adds unique keys" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")

      true = PySet.add(obj, a)
      assert true == PySet.contains(obj, a)
      assert 1 == PySet.size(obj)

      true = PySet.add(obj, a)
      assert true == PySet.contains(obj, a)
      assert 1 == PySet.size(obj)
    end
  end

  describe "discard/2" do
    test "returns true if found and removed" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")
      true = PySet.add(obj, a)
      assert 1 == PySet.size(obj)

      assert true == PySet.discard(obj, a)
      assert false == PySet.contains(obj, a)
      assert 0 == PySet.size(obj)
    end

    test "returns false if not found" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      true = PySet.add(obj, a)
      assert 1 == PySet.size(obj)

      assert false == PySet.discard(obj, b)
      assert true == PySet.contains(obj, a)
      assert 1 == PySet.size(obj)
    end
  end

  describe "pop/1" do
    test "returns an arbitrary object in the set and remove it" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")

      true = PySet.add(obj, a)
      true = PySet.add(obj, b)
      true = PySet.add(obj, c)
      assert 3 == PySet.size(obj)

      assert true == PySet.contains(obj, a)
      assert true == PySet.contains(obj, b)
      assert true == PySet.contains(obj, c)

      popped_obj = []
      popped = PySet.pop(obj)
      assert is_reference(popped)
      assert 2 == PySet.size(obj)
      assert false == PySet.contains(obj, popped)
      popped_obj = [PyUnicode.as_utf8(popped) | popped_obj]

      popped = PySet.pop(obj)
      assert is_reference(popped)
      assert 1 == PySet.size(obj)
      assert false == PySet.contains(obj, popped)
      popped_obj = [PyUnicode.as_utf8(popped) | popped_obj]

      popped = PySet.pop(obj)
      assert is_reference(popped)
      assert 0 == PySet.size(obj)
      assert false == PySet.contains(obj, popped)
      popped_obj = [PyUnicode.as_utf8(popped) | popped_obj]

      assert MapSet.equal?(MapSet.new(["a", "b", "c"]), MapSet.new(popped_obj))
    end
  end

  describe "clear/1" do
    test "empty an existing set of all elements" do
      obj = PySet.new(nil)
      a = PyUnicode.from_string("a")
      b = PyUnicode.from_string("b")
      c = PyUnicode.from_string("c")

      true = PySet.add(obj, a)
      true = PySet.add(obj, b)
      true = PySet.add(obj, c)
      assert 3 == PySet.size(obj)

      assert true == PySet.clear(obj)
      assert 0 == PySet.size(obj)
    end
  end
end
