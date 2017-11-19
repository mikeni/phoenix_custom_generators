defmodule PhoenixCustomGenerators.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phoenix_custom_generators,
      version: "1.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      source_url: "https://github.com/mikeni/phoenix_custom_generators",
      package: package(),
      description: description(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ecto, "~> 2.1"}, # support for native date, time, datetime types
      {:phoenix, "~> 1.3"},
      {:ex_doc, "~> 0.7", only: :dev},
    ]
  end

  defp description() do
    "Phoenix Generators with ExMachina and JaSerializer Support"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      maintainers: ["Michael Ni"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mikeni/phoenix_custom_generators"}
    ]
  end
end
