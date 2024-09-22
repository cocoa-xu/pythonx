defmodule Pythonx.C.PyFrozenSet.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyFrozenSet
  alias Pythonx.C.PyList
  alias Pythonx.C.PyObject
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  describe "check/1" do
    test "returns true for any valid frozenset objects" do
      obj = PyFrozenSet.new(nil)
      assert true == PyFrozenSet.check(obj)
    end

    test "returns false for non-frozenset objects" do
      assert false == PyFrozenSet.check(PyObject.py_none())
    end
  end

  describe "check_exact/1" do
    test "returns true only for frozenset objects" do
      obj = PyFrozenSet.new(nil)
      assert true == PyFrozenSet.check_exact(obj)
    end
  end

  describe "new/1" do
    test "returns a reference with nil" do
      obj = PyFrozenSet.new(nil)
      assert is_reference(obj)

      assert true == PyFrozenSet.check(obj)
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

      obj = PyFrozenSet.new(list)
      assert is_reference(obj)

      assert true == PyFrozenSet.check(obj)
    end
  end
end
