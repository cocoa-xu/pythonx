defmodule Pythonx.MixProject do
  use Mix.Project

  @app :pythonx
  @version "0.1.0"
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
      files: ~w(c_src lib mix.exs README* LICENSE* Makefile CMakeLists.txt checksum.exs, scripts),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
