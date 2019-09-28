defmodule TestReflector.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_reflector,
      version: "0.1.2",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      files: ~w(lib  .formatter.exs mix.exs README*  LICENSE* CHANGELOG* ),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/mwindholtz/test_reflector"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "TestReflector helps in writting unit testing pure functions"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
