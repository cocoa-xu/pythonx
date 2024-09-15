defmodule Pythonx.Codec.Encoder.Test do
  use ExUnit.Case, async: false

  alias Pythonx.Beam.PyObject
  alias Pythonx.C.PyDict
  alias Pythonx.C.PyFloat
  alias Pythonx.C.PyList
  alias Pythonx.C.PyLong
  alias Pythonx.C.PyObject, as: CPyObject
  alias Pythonx.C.PyTuple
  alias Pythonx.C.PyUnicode

  setup do
    Pythonx.initialize_once()
  end

  describe "encode/1" do
    test "encodes an Atom as a PyUnicode object" do
      encoded = Pythonx.Codec.Encoder.encode(:elixir)
      assert "str" == PyObject.type(encoded)
      assert "elixir" == PyUnicode.as_utf8(encoded.ref)
    end

    test "encodes a BitString as a PyUnicode object" do
      encoded = Pythonx.Codec.Encoder.encode("foo")
      assert "str" == PyObject.type(encoded)
      assert "foo" == PyUnicode.as_utf8(encoded.ref)
    end

    test "encodes a Float as a PyFloat object" do
      encoded = Pythonx.Codec.Encoder.encode(42.42)
      assert "float" == PyObject.type(encoded)
      assert_in_delta 42.42, PyFloat.as_double(encoded.ref), 0.0001
    end

    test "encodes an Integer as a PyLong object" do
      encoded = Pythonx.Codec.Encoder.encode(1000)
      assert "int" == PyObject.type(encoded)
      assert 1000 == PyLong.as_long(encoded.ref)
    end

    test "encodes a List as a PyList object" do
      encoded = Pythonx.Codec.Encoder.encode([1000, 2000, 3000, 4000, 5000])
      assert "list" == PyObject.type(encoded)

      obj = encoded.ref
      assert 5 == PyList.size(obj)

      for i <- 1..5 do
        assert i * 1000 == PyLong.as_long(PyList.get_item(obj, i - 1))
      end
    end

    test "encodes a Map as a PyDict object" do
      encoded = Pythonx.Codec.Encoder.encode(%{a: 1000, b: 2000, c: 3000})
      assert "dict" == PyObject.type(encoded)

      obj = encoded.ref
      assert 3 == PyDict.size(obj)

      keys = ["a", "b", "c"]

      for key <- keys do
        key_obj = PyUnicode.from_string(key)
        val = PyDict.get_item_with_error(obj, key_obj)
        assert is_reference(val)
        assert key == PyUnicode.as_utf8(key_obj)
        assert key == PyUnicode.as_utf8(PyUnicode.from_string(key))
      end
    end

    test "encodes a complex Map as a PyDict object" do
      encoded = Pythonx.Codec.Encoder.encode(%{"a" => 1000, 2000 => 3000, "map" => %{"foo" => 3000, "bar" => 4000}})
      assert "dict" == PyObject.type(encoded)

      obj = encoded.ref
      assert 3 == PyDict.size(obj)

      dict_keys = PyDict.keys(obj)
      assert 3 == PyList.size(dict_keys)
      dict_keys = Enum.map(0..2, &PyUnicode.as_utf8(CPyObject.str(PyList.get_item(dict_keys, &1))))
      assert MapSet.equal?(MapSet.new(["a", "2000", "map"]), MapSet.new(dict_keys))
    end

    test "encodes a Tuple as a PyTuple object" do
      encoded = Pythonx.Codec.Encoder.encode({1000, 42.42, "foo", :bar, %{"a" => {2000, 3000, 4000}}})
      assert "tuple" == PyObject.type(encoded)

      obj = encoded.ref
      assert 5 == PyTuple.size(obj)

      item_0 = PyTuple.get_item(obj, 0)
      assert is_reference(item_0)
      assert 1000 == PyLong.as_long(item_0)

      item_1 = PyTuple.get_item(obj, 1)
      assert_in_delta 42.42, PyFloat.as_double(item_1), 0.0001

      item_2 = PyTuple.get_item(obj, 2)
      assert "foo" == PyUnicode.as_utf8(item_2)

      item_3 = PyTuple.get_item(obj, 3)
      assert "bar" == PyUnicode.as_utf8(item_3)

      item_4 = PyTuple.get_item(obj, 4)
      dict_keys = PyDict.keys(item_4)
      assert 1 == PyList.size(dict_keys)
      assert "a" == PyUnicode.as_utf8(PyList.get_item(dict_keys, 0))

      dict_values = PyDict.values(item_4)
      assert 1 == PyList.size(dict_values)

      dict_values = PyList.get_item(dict_values, 0)
      assert 3 == PyTuple.size(dict_values)

      item_0 = PyTuple.get_item(dict_values, 0)
      assert 2000 == PyLong.as_long(item_0)

      item_1 = PyTuple.get_item(dict_values, 1)
      assert 3000 == PyLong.as_long(item_1)

      item_2 = PyTuple.get_item(dict_values, 2)
      assert 4000 == PyLong.as_long(item_2)
    end
  end
end
