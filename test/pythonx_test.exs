defmodule Pythonx.Test do
  use ExUnit.Case, async: true
  doctest Pythonx
  import Pythonx

  test "return and define variables that affect the context" do
    python_home = "#{:code.priv_dir(:pythonx)}/python3"
    Pythonx.initialize(python_home)

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

    Pythonx.finalize()

    assert {25, 6, {5, 6}} == {x, y, z}

    # end

    # test "preserves previous variables" do
    Pythonx.initialize(python_home)

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
    Pythonx.finalize()

    # end

    # test "does not preserve previous variables after a finialize call" do
    Pythonx.initialize(python_home)

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
  end
end
