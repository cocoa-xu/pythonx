defmodule Pythonx.C.PyNumber.Test do
  use ExUnit.Case, async: false

  alias Pythonx.C.PyErr
  alias Pythonx.C.PyFloat
  alias Pythonx.C.PyIndex
  alias Pythonx.C.PyLong
  alias Pythonx.C.PyNumber
  alias Pythonx.C.PyObject
  alias Pythonx.C.PyTuple
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  describe "check/1" do
    test "returns true for PyLong" do
      obj = PyLong.from_long(1000)
      assert true == PyNumber.check(obj)
    end

    test "returns true for PyFloat" do
      obj = PyFloat.from_double(4.2)
      assert true == PyNumber.check(obj)
    end

    test "returns false for PyObject.py_none()" do
      assert false == PyNumber.check(PyObject.py_none())
    end
  end

  def get({:long, val}), do: {PyLong.from_long(val), val}
  def get({:float, val}), do: {PyFloat.from_double(val), val}

  def get_result(pyfunc, erl_func, a, b) when is_function(pyfunc, 2) and is_function(erl_func, 2) do
    {o1, a} = get(a)
    {o2, b} = get(b)
    {pyfunc.(o1, o2), erl_func.(a, b)}
  end

  def get_in_place_result(pyfunc, erl_func, a, b) when is_function(pyfunc, 2) and is_function(erl_func, 2) do
    {o1, a} = get(a)
    {o2, b} = get(b)
    {pyfunc.(o1, o2), o1, erl_func.(a, b)}
  end

  @a {:long, 1000}
  @b {:long, 2000}
  @c {:float, 4.2}
  @d {:float, 3.3}

  def binary_functions do
    [
      add: {&PyNumber.add/2, &+/2},
      subtract: {&PyNumber.subtract/2, &-/2},
      multiply: {&PyNumber.multiply/2, &*/2},
      floor_divide: {&PyNumber.floor_divide/2, &Float.floor(&1 * 1.0 / &2)},
      true_divide: {&PyNumber.true_divide/2, &(&1 * 1.0 / &2)},
      remainder:
        {&PyNumber.remainder/2,
         fn a, b ->
           {a, b, c} =
             case {a < 0, b < 0} do
               {true, true} -> {-a, -b, 0}
               {true, false} -> {-a, b, a}
               {false, true} -> {a, -b, b}
               {false, false} -> {a, b, 0}
             end

           multiplies = trunc(a / b)
           a - multiplies * b + c
         end}
    ]
  end

  binary_function_names = [:add, :subtract, :multiply, :floor_divide, :true_divide, :remainder]

  for func_name <- binary_function_names do
    describe "#{func_name}/2" do
      @func_name func_name
      test "returns the result of two PyLong" do
        {pyfunc, erlfunc} = binary_functions()[@func_name]
        {o1, a} = get(@a)
        {o2, b} = get(@b)
        result = pyfunc.(o1, o2)

        expected =
          case @func_name do
            :true_divide ->
              div(a, b)

            _ ->
              erlfunc.(a, b)
          end

        assert is_reference(result)
        assert_in_delta PyLong.as_long(result), expected, 0.01
      end

      test "returns the result of two PyFloat" do
        {pyfunc, erlfunc} = binary_functions()[@func_name]
        {result, expected} = get_result(pyfunc, erlfunc, @c, @d)
        assert is_reference(result)
        assert_in_delta PyFloat.as_double(result), expected, 0.01
      end

      test "returns the result of a PyLong and a PyFloat" do
        {pyfunc, erlfunc} = binary_functions()[@func_name]
        {result, expected} = get_result(pyfunc, erlfunc, @a, @c)
        assert is_reference(result)
        assert_in_delta PyFloat.as_double(result), expected, 0.01
      end

      test "returns the result of a PyFloat and a PyLong" do
        {pyfunc, erlfunc} = binary_functions()[@func_name]
        {result, expected} = get_result(pyfunc, erlfunc, @c, @b)
        assert is_reference(result)
        assert_in_delta PyFloat.as_double(result), expected, 0.01
      end

      test "returns PyErr.t() when the first argument is not a number" do
        {pyfunc, _erlfunc} = binary_functions()[@func_name]
        obj1 = PyObject.py_none()
        obj2 = PyLong.from_long(0)
        result = pyfunc.(obj1, obj2)
        assert %PyErr{} = result
      end
    end
  end

  describe "divmod/2" do
    test "returns the result of two PyLong" do
      {o1, a} = get(@a)
      {o2, b} = get(@b)
      result = PyNumber.divmod(o1, o2)
      assert is_reference(result)
      assert PyTuple.check(result)
      assert 2 == PyTuple.size(result)

      {div, mod} = {PyTuple.get_item(result, 0), PyTuple.get_item(result, 1)}
      assert is_reference(div)
      assert is_reference(mod)

      assert_in_delta PyLong.as_long(div), div(a, b), 0.01
      assert_in_delta PyLong.as_long(mod), rem(a, b), 0.01
    end

    test "returns the result of two PyFloat" do
      {o1, c} = get(@c)
      {o2, d} = get(@d)
      result = PyNumber.divmod(o1, o2)
      assert is_reference(result)
      assert PyTuple.check(result)
      assert 2 == PyTuple.size(result)

      {div, mod} = {PyTuple.get_item(result, 0), PyTuple.get_item(result, 1)}
      assert is_reference(div)
      assert is_reference(mod)

      assert_in_delta PyFloat.as_double(div), trunc(c / d), 0.01
      assert_in_delta PyFloat.as_double(mod), c - trunc(c / d) * d, 0.01
    end

    test "returns PyErr.t() when the first argument is not a number" do
      obj1 = PyObject.py_none()
      obj2 = PyLong.from_long(0)
      result = PyNumber.divmod(obj1, obj2)
      assert %PyErr{} = result
    end
  end

  describe "power/3" do
    test "pow(10, 2)" do
      o1 = PyLong.from_long(10)
      o2 = PyLong.from_long(2)
      result = PyNumber.power(o1, o2, PyObject.py_none())
      assert PyLong.as_long(result) == 100
    end

    test "pow(10, -2)" do
      o1 = PyLong.from_long(10)
      o2 = PyLong.from_long(-2)
      result = PyNumber.power(o1, o2, PyObject.py_none())
      assert_in_delta 0.01, PyFloat.as_double(result), 0.0001
    end

    test "pow(-9, 2.0)" do
      o1 = PyLong.from_long(-9)
      o2 = PyFloat.from_double(2.0)
      result = PyNumber.power(o1, o2, PyObject.py_none())
      assert_in_delta 81, PyFloat.as_double(result), 0.0001
    end

    test "pow(38, -1, mod=97)" do
      o1 = PyLong.from_long(38)
      o2 = PyLong.from_long(-1)
      o3 = PyLong.from_long(97)
      result = PyNumber.power(o1, o2, o3)
      assert PyLong.as_long(result) == 23
    end
  end

  describe "negative/1" do
    test "returns the negative of a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.negative(o)
      assert PyLong.as_long(result) == -val

      val = -val
      o = PyLong.from_long(val)
      result = PyNumber.negative(o)
      assert PyLong.as_long(result) == -val
    end

    test "returns the negative of a PyFloat" do
      val = 42.42
      o = PyFloat.from_double(val)
      result = PyNumber.negative(o)
      assert_in_delta PyFloat.as_double(result), -val, 0.0001

      val = -val
      o = PyFloat.from_double(val)
      result = PyNumber.negative(o)
      assert_in_delta PyFloat.as_double(result), -val, 0.0001
    end

    test "returns PyErr.t() when the argument is not a number" do
      obj = PyObject.py_none()
      result = PyNumber.negative(obj)
      assert %PyErr{} = result
    end
  end

  describe "positive/1" do
    test "returns the positive of a PyLong" do
      val = -42
      o = PyLong.from_long(val)
      result = PyNumber.positive(o)
      assert PyLong.as_long(result) == +val

      val = -val
      o = PyLong.from_long(val)
      result = PyNumber.positive(o)
      assert PyLong.as_long(result) == +val
    end

    test "returns the positive of a PyFloat" do
      val = -42.42
      o = PyFloat.from_double(val)
      result = PyNumber.positive(o)
      assert_in_delta PyFloat.as_double(result), +val, 0.0001

      val = -val
      o = PyFloat.from_double(val)
      result = PyNumber.positive(o)
      assert_in_delta PyFloat.as_double(result), +val, 0.0001
    end

    test "returns PyErr.t() when the argument is not a number" do
      obj = PyObject.py_none()
      result = PyNumber.positive(obj)
      assert %PyErr{} = result
    end
  end

  describe "absolute/1" do
    test "returns the absolute of a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.absolute(o)
      assert PyLong.as_long(result) == abs(val)

      val = -val
      o = PyLong.from_long(val)
      result = PyNumber.absolute(o)
      assert PyLong.as_long(result) == abs(val)
    end

    test "returns the absolute of a PyFloat" do
      val = 42.42
      o = PyFloat.from_double(val)
      result = PyNumber.absolute(o)
      assert_in_delta PyFloat.as_double(result), abs(val), 0.0001

      val = -val
      o = PyFloat.from_double(val)
      result = PyNumber.absolute(o)
      assert_in_delta PyFloat.as_double(result), abs(val), 0.0001
    end

    test "returns PyErr.t() when the argument is not a number" do
      obj = PyObject.py_none()
      result = PyNumber.absolute(obj)
      assert %PyErr{} = result
    end
  end

  describe "invert/1" do
    test "returns the bitwise negation of a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.invert(o)
      assert PyLong.as_long(result) == Bitwise.bnot(val)

      val = -val
      o = PyLong.from_long(val)
      result = PyNumber.invert(o)
      assert PyLong.as_long(result) == Bitwise.bnot(val)
    end

    test "returns PyErr.t() when the argument is not an int" do
      obj = PyFloat.from_double(4.2)
      result = PyNumber.invert(obj)
      assert %PyErr{} = result

      obj = PyObject.py_none()
      result = PyNumber.invert(obj)
      assert %PyErr{} = result
    end
  end

  describe "lshift/2" do
    test "returns the result of left shifting o1 by o2" do
      a = 0b1010
      b = 2
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.lshift(o1, o2)
      assert PyLong.as_long(result) == Bitwise.<<<(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.lshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.lshift(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.lshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.lshift(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "rshift/2" do
    test "returns the result of right shifting o1 by o2" do
      a = 0b1010
      b = 2
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.rshift(o1, o2)
      assert PyLong.as_long(result) == Bitwise.>>>(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.rshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.rshift(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.rshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.rshift(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "band/2" do
    test "returns the result of `bitwise and` of o1 and o2" do
      a = 0b1010
      b = 0b1100
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.band(o1, o2)
      assert PyLong.as_long(result) == Bitwise.band(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.band(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.band(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.band(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.band(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "bxor/2" do
    test "returns the result of `bitwise exclusive or` of o1 and o2" do
      a = 0b1010
      b = 0b1100
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.bxor(o1, o2)
      assert PyLong.as_long(result) == Bitwise.bxor(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.bxor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.bxor(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.bxor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.bxor(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "bor/2" do
    test "returns the result of `bitwise or` of o1 and o2" do
      a = 0b1010
      b = 0b1100
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.bor(o1, o2)
      assert PyLong.as_long(result) == Bitwise.bor(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.bor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.bor(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.bor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.bor(o2, o1)
      assert %PyErr{} = result
    end
  end

  def in_place_binary_functions do
    [
      in_place_add: {&PyNumber.in_place_add/2, &+/2},
      in_place_subtract: {&PyNumber.in_place_subtract/2, &-/2},
      in_place_multiply: {&PyNumber.in_place_multiply/2, &*/2},
      in_place_floor_divide: {&PyNumber.in_place_floor_divide/2, &Float.floor(&1 * 1.0 / &2)},
      in_place_true_divide: {&PyNumber.in_place_true_divide/2, &(&1 * 1.0 / &2)},
      in_place_remainder:
        {&PyNumber.in_place_remainder/2,
         fn a, b ->
           {a, b, c} =
             case {a < 0, b < 0} do
               {true, true} -> {-a, -b, 0}
               {true, false} -> {-a, b, a}
               {false, true} -> {a, -b, b}
               {false, false} -> {a, b, 0}
             end

           multiplies = trunc(a / b)
           a - multiplies * b + c
         end}
    ]
  end

  in_place_binary_function_names = [
    :in_place_add,
    :in_place_subtract,
    :in_place_multiply,
    :in_place_floor_divide,
    :in_place_true_divide,
    :in_place_remainder
  ]

  for func_name <- in_place_binary_function_names do
    describe "#{func_name}/2" do
      @func_name func_name
      test "returns the result of two PyLong" do
        {pyfunc, erlfunc} = in_place_binary_functions()[@func_name]
        {o1, a} = get(@a)
        {o2, b} = get(@b)
        result = pyfunc.(o1, o2)

        expected =
          case @func_name do
            :in_place_true_divide ->
              div(a, b)

            _ ->
              erlfunc.(a, b)
          end

        assert is_reference(result)
        assert_in_delta PyLong.as_long(result), expected, 0.01
      end

      test "returns the result of two PyFloat" do
        {pyfunc, erlfunc} = in_place_binary_functions()[@func_name]
        {result, _o1, expected} = get_in_place_result(pyfunc, erlfunc, @c, @d)
        assert is_reference(result)
        assert_in_delta PyFloat.as_double(result), expected, 0.01
      end

      test "returns the result of a PyLong and a PyFloat" do
        {pyfunc, erlfunc} = in_place_binary_functions()[@func_name]
        {result, _o1, expected} = get_in_place_result(pyfunc, erlfunc, @a, @c)
        assert is_reference(result)
        assert_in_delta PyFloat.as_double(result), expected, 0.01
      end

      test "returns the result of a PyFloat and a PyLong" do
        {pyfunc, erlfunc} = in_place_binary_functions()[@func_name]
        {result, _o1, expected} = get_in_place_result(pyfunc, erlfunc, @c, @b)
        assert is_reference(result)
        assert_in_delta PyFloat.as_double(result), expected, 0.01
      end

      test "returns PyErr.t() when the first argument is not a number" do
        {pyfunc, _erlfunc} = in_place_binary_functions()[@func_name]
        obj1 = PyObject.py_none()
        obj2 = PyLong.from_long(0)
        result = pyfunc.(obj1, obj2)
        assert %PyErr{} = result
      end
    end
  end

  describe "in_place_power/3" do
    test "pow(10, 2)" do
      o1 = PyLong.from_long(10)
      o2 = PyLong.from_long(2)
      result = PyNumber.in_place_power(o1, o2, PyObject.py_none())
      assert PyLong.as_long(result) == 100
    end

    test "pow(10, -2)" do
      o1 = PyLong.from_long(10)
      o2 = PyLong.from_long(-2)
      result = PyNumber.in_place_power(o1, o2, PyObject.py_none())
      assert_in_delta 0.01, PyFloat.as_double(result), 0.0001
    end

    test "pow(-9, 2.0)" do
      o1 = PyLong.from_long(-9)
      o2 = PyFloat.from_double(2.0)
      result = PyNumber.in_place_power(o1, o2, PyObject.py_none())
      assert_in_delta 81, PyFloat.as_double(result), 0.0001
    end

    test "pow(38, -1, mod=97)" do
      o1 = PyLong.from_long(38)
      o2 = PyLong.from_long(-1)
      o3 = PyLong.from_long(97)
      result = PyNumber.in_place_power(o1, o2, o3)
      assert PyLong.as_long(result) == 23
    end
  end

  describe "in_place_lshift/2" do
    test "returns the result of left shifting o1 by o2" do
      a = 0b1010
      b = 2
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.in_place_lshift(o1, o2)
      assert PyLong.as_long(result) == Bitwise.<<<(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_lshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_lshift(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_lshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_lshift(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "in_place_rshift/2" do
    test "returns the result of right shifting o1 by o2" do
      a = 0b1010
      b = 2
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.in_place_rshift(o1, o2)
      assert PyLong.as_long(result) == Bitwise.>>>(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_rshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_rshift(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_rshift(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_rshift(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "in_place_band/2" do
    test "returns the result of `bitwise and` of o1 and o2" do
      a = 0b1010
      b = 0b1100
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.in_place_band(o1, o2)
      assert PyLong.as_long(result) == Bitwise.band(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_band(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_band(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_band(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_band(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "in_place_bxor/2" do
    test "returns the result of `bitwise exclusive or` of o1 and o2" do
      a = 0b1010
      b = 0b1100
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.in_place_bxor(o1, o2)
      assert PyLong.as_long(result) == Bitwise.bxor(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_bxor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_bxor(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_bxor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_bxor(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "in_place_bor/2" do
    test "returns the result of `bitwise or` of o1 and o2" do
      a = 0b1010
      b = 0b1100
      o1 = PyLong.from_long(a)
      o2 = PyLong.from_long(b)
      result = PyNumber.in_place_bor(o1, o2)
      assert PyLong.as_long(result) == Bitwise.bor(a, b)
    end

    test "returns PyErr.t() when the arguments are not both integers" do
      o1 = PyFloat.from_double(4.2)
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_bor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_bor(o2, o1)
      assert %PyErr{} = result

      o1 = PyObject.py_none()
      o2 = PyLong.from_long(1)
      result = PyNumber.in_place_bor(o1, o2)
      assert %PyErr{} = result
      result = PyNumber.in_place_bor(o2, o1)
      assert %PyErr{} = result
    end
  end

  describe "long/1" do
    test "returns int(o) for a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.long(o)
      assert PyLong.check(result)
      assert PyLong.as_long(result) == val
    end

    test "returns int(o) for a PyFloat" do
      val = 4.2
      o = PyFloat.from_double(val)
      result = PyNumber.long(o)
      assert PyLong.check(result)
      assert PyLong.as_long(result) == trunc(val)
    end

    test "returns PyErr.t() when the argument is not a number" do
      obj = PyObject.py_none()
      result = PyNumber.long(obj)
      assert %PyErr{} = result
    end
  end

  describe "float/1" do
    test "returns float(o) for a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.float(o)
      assert PyFloat.check(result)
      assert PyLong.as_long(result) == val
    end

    test "returns float(o) for a PyFloat" do
      val = 4.2
      o = PyFloat.from_double(val)
      result = PyNumber.float(o)
      assert PyFloat.check(result)
      assert PyLong.as_long(result) == trunc(val)
    end

    test "returns PyErr.t() when the argument is not a number" do
      obj = PyObject.py_none()
      result = PyNumber.float(obj)
      assert %PyErr{} = result
    end
  end

  describe "index/1" do
    test "returns result for a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.index(o)
      assert PyLong.check(result)
      assert PyIndex.check(result)
      assert PyLong.as_long(result) == val
    end

    test "returns PyErr.t() when the argument is not an integer" do
      val = 4.2
      o = PyFloat.from_double(val)
      result = PyNumber.index(o)
      assert %PyErr{} = result

      obj = PyObject.py_none()
      result = PyNumber.index(obj)
      assert %PyErr{} = result
    end
  end

  describe "to_base/2" do
    test "returns the base 2 representation of a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.to_base(o, 2)
      assert "0b101010" == PyUnicode.as_utf8(result)
    end

    test "returns the base 8 representation of a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.to_base(o, 8)
      assert "0o52" == PyUnicode.as_utf8(result)
    end

    test "returns the base 10 representation of a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.to_base(o, 10)
      assert "42" == PyUnicode.as_utf8(result)
    end

    test "returns the base 16 representation of a PyLong" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.to_base(o, 16)
      assert "0x2a" == PyUnicode.as_utf8(result)
    end
  end

  describe "as_ssize_t/1" do
    test "returns the value of a PyLong with exc == nil" do
      val = 42
      o = PyLong.from_long(val)
      result = PyNumber.as_ssize_t(o, nil)
      assert val == result
    end
  end
end
