defmodule Pythonx.Test do
  use ExUnit.Case
  doctest Pythonx
  import Pythonx

  test "return and define variables that affect the context" do
    pyeval(
      """
      import math
      x = 5
      y = 6
      z = (x, y)
      x = math.pow(x, 2)
      """,
      return: [:x, :y, :z]
    )

    assert {25, 6, {5, 6}} == {x, y, z}
  end
end
