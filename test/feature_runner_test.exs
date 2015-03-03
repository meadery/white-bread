defmodule WhiteBread.FeatureRunnerTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario
  alias WhiteBread.FeatureRunnerTest.ExampleContext, as: ExampleContext

  test "Fails if a step fails an assertion" do
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"}
    ]

    scenario = %Scenario{name: "test scenario", steps: steps}
    feature = %Feature{name: "test feature", scenarios: [scenario]}
    output = WhiteBread.Outputers.Console.start

    result = WhiteBread.FeatureRunner.run(ExampleContext, feature, output)
    IO.puts "#{inspect result}"
    output |> WhiteBread.Outputers.Console.stop
  end
end

defmodule WhiteBread.FeatureRunnerTest.ExampleContext do
  use WhiteBread.Context

  when_ "step one", fn _state ->
    {:ok, :step_one_complete}
  end

  when_ "step that blocks step two", fn _state ->
    {:ok, :unexpected_state}
  end

  when_ "step two", fn :step_one_complete ->
    {:ok, :step_two_complete}
  end

  when_ "make a failing assestion", fn _state ->
    assert 1 == 0
    {:ok, :impossible}
  end

end
