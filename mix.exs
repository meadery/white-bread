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
     version: "4.5.0",
     elixir: "~> 1.2",
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {WhiteBread.Application, []},
     applications: [:logger],
     env: [outputers: [{WhiteBread.Outputers.Console, []}]
          ]
    ]
  end

  defp aliases do
    [ci_tests: ci_mix_tests()]
  end

  defp ci_mix_tests do
    [
      &set_test_env/1,
      "compile --warnings-as-errors",
      "test",
      "whiteBread.run",
      "white_bread.run --suite \"Plain context - Songs\""
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
      {:gherkin, "~> 1.4"},
      {:poison, "~> 3.1", optional: true},

      {:credo, "~> 0.8", only: :dev},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp set_test_env(_) do
    Mix.env(:test)
  end
end
