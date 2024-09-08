defmodule Pythonx.Test do
  use ExUnit.Case, async: false
  doctest Pythonx
  import Pythonx

  setup do
    Pythonx.initialize_once()
  end

  test "return and define variables that affect the context, and preserves previous variables" do
    pyeval(
      """
      import math
      x = 5
      y = 6
      """,
      return: [:x, :y]
    )

    assert {5, 6} == {x, y}

    pyeval(
      """
      z = (x, y)
      x = math.pow(x, 2)
      """,
      return: [:x, :y, :z]
    )

    assert {25, 6, {5, 6}} == {x, y, z}
  end
end
