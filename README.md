# Pythonx

[![Hex.pm](https://img.shields.io/hexpm/v/pythonx.svg?style=flat&color=blue)](https://hex.pm/packages/pythonx)

Python Interpreter in Elixir

> [!IMPORTANT]
> Pythonx is still very much a work in progress and is mainly intended for some proof of concept at current stage. 

## Proof of Concept

#### Python Code Evaluation
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

#### Executes a command with the embedded python3 executable

```elixir
iex> import Pythonx
iex> python3! "path/to/script.py"
iex> python3! ["path/to/script.py", "arg1", "arg2"]
```

#### Executes a command with the embedded pip module

```elixir
iex> import Pythonx
iex> pip! ["install", "-U", "numpy"]
iex> pip! ["install", "-U", "yt-dlp"]
```

#### Use an external python library

```elixir
iex> import Pythonx
iex> video_id = "dQw4w9WgXcQ"
iex> pyeval(
...>   """
...>   from yt_dlp import YoutubeDL
...>   import json
...>   with YoutubeDL(params={'quite': True}) as ytb_dl:
...>   info = ytb_dl.extract_info('https://www.youtube.com/watch?v=#{video_id}', download=False)
...>   info = json.dumps(info, indent=2)
...>   """,
...>   return: [:info]
...> )
[youtube] Extracting URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ
[youtube] dQw4w9WgXcQ: Downloading webpage
[youtube] dQw4w9WgXcQ: Downloading ios player API JSON
[youtube] dQw4w9WgXcQ: Downloading player a95aa57a
[youtube] dQw4w9WgXcQ: Downloading m3u8 information
iex> IO.puts(info)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pythonx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pythonx, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pythonx>.

