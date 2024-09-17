ExUnit.configure(
  exclude: [
    pyinline: true,
    pyeval: true,
    c_pyrun: true,
    flaky: true
  ]
)

ExUnit.start()
