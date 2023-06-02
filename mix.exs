defmodule GrizzlyDevUtils.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :grizzly_dev_utils,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      preferred_cli_env: [docs: :docs, "hex.publish": :docs]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :docs, runtime: false},
      {:exqlite, "~> 0.13"},
      {:grizzly, "~> 6.6"}
    ]
  end

  defp description() do
    "Experimental dev utils for Grizzly. Use at your own risk."
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/smartrent/grizzly_dev_utils"}
    ]
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      source_url: "https://github.com/smartrent/grizzly_dev_utils"
    ]
  end
end
