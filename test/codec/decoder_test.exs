defmodule Pythonx.Codec.Decoder.Test do
  use ExUnit.Case, async: false

  alias Pythonx.Beam.PyFloat
  alias Pythonx.Beam.PyList
  alias Pythonx.Beam.PyLong
  alias Pythonx.Beam.PyObject
  alias Pythonx.Beam.PyTuple
  alias Pythonx.Beam.PyUnicode
  alias Pythonx.C.PyFloat, as: CPyFloat
  alias Pythonx.C.PyList, as: CPyList
  alias Pythonx.C.PyLong, as: CPyLong
  alias Pythonx.C.PyObject, as: CPyObject
  alias Pythonx.C.PyUnicode, as: CPyUnicode

  setup do
    Pythonx.initialize_once()
  end

  describe "decoding" do
    test "decodes a PyFloat object to a Float" do
      ref = CPyFloat.from_double(42.42)
      obj = %PyFloat{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert_in_delta 42.42, decoded, 0.0001
    end

    test "decodes a PyList object to an Integer" do
      ref = CPyList.new(0)
      CPyList.append(ref, CPyLong.from_long(42))
      CPyList.append(ref, CPyLong.from_long(43))
      obj = %PyList{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert [42, 43] == decoded
    end

    test "decodes a PyLong object to an Integer" do
      ref = CPyLong.from_long(42)
      obj = %PyLong{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert 42 == decoded
    end

    test "decodes a None to nil" do
      ref = CPyObject.py_none()
      obj = %PyObject{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert nil == decoded
    end

    test "decodes a True to true" do
      ref = CPyObject.py_true()
      obj = %PyObject{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert true == decoded
    end

    test "decodes a False to false" do
      ref = CPyObject.py_false()
      obj = %PyObject{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert false == decoded
    end

    test "decodes a PyObject object to appropriate types" do
      ref = CPyList.new(0)
      CPyList.append(ref, CPyLong.from_long(42))
      CPyList.append(ref, CPyLong.from_long(43))
      obj = %PyObject{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert [42, 43] == decoded
    end

    test "decodes a PyTuple object to a Tuple" do
      list = CPyList.new(0)
      a = CPyUnicode.from_string("a")
      b = CPyUnicode.from_string("b")
      c = CPyUnicode.from_string("c")
      CPyList.append(list, a)
      CPyList.append(list, b)
      CPyList.append(list, c)
      ref = CPyList.as_tuple(list)
      obj = %PyTuple{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert {"a", "b", "c"} == decoded
    end

    test "decodes a PyUnicode object to a String.t()" do
      ref = CPyUnicode.from_string("str")
      obj = %PyUnicode{ref: ref}

      decoded = Pythonx.Codec.Decoder.decode(obj)
      assert "str" == decoded
    end
  end
end
