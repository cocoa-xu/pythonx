defmodule Pythonx.C.Test do
  use ExUnit.Case, async: false

  setup do
    Pythonx.initialize_once()
  end

  test "py_print_raw/0" do
    assert is_integer(Pythonx.C.py_print_raw())
  end

  test "py_eval_input/0" do
    assert is_integer(Pythonx.C.py_eval_input())
  end

  test "py_file_input/0" do
    assert is_integer(Pythonx.C.py_file_input())
  end

  test "py_single_input/0" do
    assert is_integer(Pythonx.C.py_single_input())
  end
end
