defmodule WhiteBread.Mixfile do
  use Mix.Project

  def project do
    [app: :white_bread,
     name: "WhiteBread",
     description: """
     Story BDD tool based on cucumber.
     Parses Gherkin formatted feature files and executes them as tests.
     """,
     package: [
       maintainers: ["Steve Brazier"],
       licenses: ["MIT"],
       links: %{"GitHub" => "https://github.com/meadsteve/white-bread"},
       ],
     version: "2.8.1",
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp aliases do
    [ci_tests: ci_mix_tests]
  end

  defp ci_mix_tests do
    [
      &set_test_env/1,
      "compile --warnings-as-errors",
      "test",
      "whiteBread.run",
      "whiteBread.run --tags songs",
      "white_bread.run --context \"features/contexts/alternate_context.exs\"",
    ]
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
      {:credo, "0.4.11", only: [:dev]},
      {:earmark, "~> 1.0.1", only: :dev},
      {:ex_doc, "~> 0.8", only: :dev}
    ]
  end

  defp set_test_env(_) do
    Mix.env(:test)
  end
end
