# Pythonx

Python Interpreter in Elixir

## Proof of Concept

### Python Code Evaluation
```elixir
defmodule MyModule do
  import Pythonx

  def do_stuff_in_python do
    pyeval(
      """
      import math
      x = 5
      y = 6
      z = (x, y)
      x = math.pow(x, 2)
      """,
      return: [:x, :y, :z] # <- list of variables to return to Elixir
    )
    
    # these variables will be automatically defined in the current scope
    # {25, 6, {5, 6}} == {x, y, z}
  end
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pybeam` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pybeam, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pybeam>.

