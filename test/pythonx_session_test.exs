defmodule Pythonx.SessionTest do
  use ExUnit.Case, async: false
  import Pythonx

  @tag :pyeval
  test "does not preserve previous variables after a finialize call" do
    Pythonx.initialize()

    pyeval(
      """
      import math
      x = 5
      y = 6
      """,
      return: [:x, :y]
    )

    assert {5, 6} == {x, y}
    Pythonx.finalize()

    Pythonx.initialize()

    assert_raise RuntimeError, "python_error", fn ->
      pyeval(
        """
        z = (x, y)
        x = math.pow(x, 2)
        """,
        return: [:x]
      )

      assert x == x
    end

    Pythonx.finalize()
  end
end
