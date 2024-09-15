# Pythonx

[![Hex.pm](https://img.shields.io/hexpm/v/pythonx.svg?style=flat&color=blue)](https://hex.pm/packages/pythonx)

Python Interpreter in Elixir

> [!IMPORTANT]
> Pythonx is still very much a work in progress and is mainly intended for some proof of concept at current stage. 

## Proof of Concept
### Low-Level

```elixir
iex> alias Pythonx.C
iex> alias Pythonx.C.PyDict
iex> alias Pythonx.C.PyLong
iex> alias Pythonx.C.PyList
iex> alias Pythonx.C.PyObject
iex> alias Pythonx.C.PyRun
iex> alias Pythonx.C.PyUnicode
iex> Pythonx.initialize_once()
iex> globals = PyDict.new()
#Reference<0.1798353731.1418330114.239105>
iex> locals = PyDict.new()
#Reference<0.1798353731.1418330114.239123>
iex> a = PyLong.from_long(1)
#Reference<0.1798353731.1418330114.239141>
iex> b = PyLong.from_long(2)
#Reference<0.1798353731.1418330114.239155>
iex> PyDict.set_item_string(locals, "a", a)
true
iex> PyDict.set_item_string(locals, "b", b)
true
iex> PyRun.string("c = a + b", C.py_file_input(), globals, locals)
#Reference<0.1798353731.1418330117.241204>
iex> c = PyUnicode.from_string("c")
#Reference<0.1798353731.1418330117.241222>
iex> val_c = PyDict.get_item_with_error(locals, c)
#Reference<0.1798353731.1418330117.241236>
iex> PyLong.as_long(val_c)
3
```

### Very High Level
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

