defmodule PybeamTest do
  use ExUnit.Case
  doctest Pybeam

  test "greets the world" do
    assert Pybeam.hello() == :world
  end
end
