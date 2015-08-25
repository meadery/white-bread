defmodule WhiteBread.Mixfile do
  use Mix.Project

  def project do
    [app: :white_bread,
     name: "WhiteBread",
     description: """
     Story BDD tool written in and for Elixir.
     Parses Gherkin formatted feature files and executes them as tests.
     """,
     package: [
       contributors: ["Steve Brazier"],
       licenses: ["MIT"],
       links: %{"GitHub" => "https://github.com/meadsteve/white-bread"},
       ],
     version: "1.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      #{:dogma, "~> 0.0.2"}
      {:dogma, git: "https://github.com/meadsteve/dogma.git", ref: "9b21429dbced0c2a5254395ee19a0a8c259d1994"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.8", only: :dev}
    ]
  end
end
