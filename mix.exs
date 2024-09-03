defmodule Pythonx.MixProject do
  use Mix.Project

  @app :pythonx
  @version "0.2.0"
  @github_url "https://github.com/cocoa-xu/pythonx"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),

      # Package information
      name: "Pythonx",
      description: "Python Interpreter in Elixir",
      package: package(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs
      ],

      # Compilers
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_precompiler: {:nif, CCPrecompiler},
      make_precompiler_url: "#{@github_url}/releases/download/v#{@version}/@{artefact_filename}",
      make_precompiler_nif_versions: [versions: ["2.16"]],
      cc_precompiler: [
        cleanup: "clean",
        only_listed_targets: true,
        compilers: %{
          {:unix, :linux} => %{
            "x86_64-linux-gnu" => {
              "x86_64-linux-gnu-gcc",
              "x86_64-linux-gnu-g++"
            },
            "aarch64-linux-gnu" => {
              "aarch64-linux-gnu-gcc",
              "aarch64-linux-gnu-g++"
            },
            "powerpc64le-linux-gnu" => {
              "powerpc64le-linux-gnu-gcc",
              "powerpc64le-linux-gnu-g++"
            },
            "riscv64-linux-gnu" => {
              "riscv64-linux-gnu-gcc",
              "riscv64-linux-gnu-g++"
            },
            "s390x-linux-gnu" => {
              "s390x-linux-gnu-gcc",
              "s390x-linux-gnu-g++"
            }
          },
          {:unix, :darwin} => %{
            "x86_64-apple-darwin" => {
              "gcc",
              "g++",
              "<%= cc %> -arch x86_64",
              "<%= cxx %> -arch x86_64"
            },
            "aarch64-apple-darwin" => {
              "gcc",
              "g++",
              "<%= cc %> -arch arm64",
              "<%= cxx %> -arch arm64"
            }
          }
        }
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.8"},
      {:cc_precompiler, "~> 0.1"},
      {:req, "~> 0.3"},
      {:ex_doc, "~> 0.34", only: :docs, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Pythonx",
      source_ref: "v#{@version}",
      source_url: @github_url
    ]
  end

  defp package do
    [
      name: "pythonx",
      files: ~w(c_src lib mix.exs README* LICENSE* Makefile CMakeLists.txt checksum.exs scripts),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
