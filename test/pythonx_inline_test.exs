defmodule Pythonx.Inline.Test do
  use ExUnit.Case, async: false

  import Pythonx

  setup do
    Pythonx.initialize_once()
  end

  @tag :pyinline
  test "inline python" do
    a = "Elixir"

    pyinline(
      """
      a = a + " 🤝"
      b = f"{a} Python!"
      """,
      return: [:a, :b]
    )

    assert {"Elixir 🤝", "Elixir 🤝 Python!"} == {a, b}
  end
end
