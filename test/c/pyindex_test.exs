defmodule Pythonx.C.PyIndex.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyIndex
  alias Pythonx.C.PyLong
  alias Pythonx.C.PyNumber
  alias Pythonx.C.PyObject

  setup do
    Pythonx.initialize_once()
  end

  test "check/1" do
    val = 42
    o = PyLong.from_long(val)
    result = PyNumber.index(o)
    assert true == PyIndex.check(result)

    assert false == PyIndex.check(PyObject.py_none())
  end
end
