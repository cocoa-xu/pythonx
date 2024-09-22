defmodule Pythonx.C.PyAnySet.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyAnySet
  alias Pythonx.C.PyFrozenSet
  alias Pythonx.C.PyObject
  alias Pythonx.C.PySet

  setup do
    Pythonx.initialize_once()
  end

  describe "check/1" do
    test "returns true for any valid set, frozenset objects, or an instance of a subtype" do
      obj = PyFrozenSet.new(nil)
      assert true == PyAnySet.check(obj)

      obj = PySet.new(nil)
      assert true == PyAnySet.check(obj)
    end

    test "returns false for non-set objects" do
      assert false == PyAnySet.check(PyObject.py_none())
    end
  end

  describe "check_exact/1" do
    test "returns true for any valid set, frozenset objects, but not for an instance of a subtype" do
      obj = PyFrozenSet.new(nil)
      assert true == PyAnySet.check(obj)

      obj = PySet.new(nil)
      assert true == PyAnySet.check(obj)
    end
  end
end
