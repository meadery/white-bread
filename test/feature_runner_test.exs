defmodule WhiteBread.Runners.FeatureRunnerTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario
  alias WhiteBread.FeatureRunnerTest.ExampleContext, as: ExampleContext

  test "feature runner should return succesful scenarios" do
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"}
    ]

    scenario = %Scenario{name: "test scenario", steps: steps}
    feature = %Feature{name: "test feature", scenarios: [scenario]}

    output = WhiteBread.Outputers.Console.start
    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, output)
    output |> WhiteBread.Outputers.Console.stop

    assert result == %{
      failures: [],
      successes: [{scenario, {:ok, "test scenario"}}]
    }
  end

  test "feature runner should return succesful and failed scenarios" do
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"}
    ]

    failing_step = %Steps.When{text: "step two"}
    failing_steps = [
      %Steps.When{text: "step that blocks step two"},
      failing_step
    ]

    scenario = %Scenario{name: "test scenario", steps: steps}
    failing_scenario = %Scenario{name: "failing scenario", steps: failing_steps}
    feature = %Feature{name: "test feature", scenarios: [scenario, failing_scenario]}

    output = WhiteBread.Outputers.Console.start
    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, output)
    output |> WhiteBread.Outputers.Console.stop

    %{
      failures: [{^failing_scenario, {:failed, {failing_reason, ^failing_step, _}}}],
      successes: [{^scenario, {:ok, "test scenario"}}]
    } = result
    assert failing_reason == :no_clause_match
  end

  test "feature runner should pass with background steps" do
    background_steps = [
      %Steps.When{text: "step one"}
    ]
    steps = [
      %Steps.When{text: "step two"}
    ]

    scenario = %Scenario{name: "test scenario", steps: steps}
    feature = %Feature{name: "test feature", scenarios: [scenario], background_steps: background_steps}

    output = WhiteBread.Outputers.Console.start
    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, output)
    output |> WhiteBread.Outputers.Console.stop

    assert result == %{
      failures: [],
      successes: [{scenario, {:ok, "test scenario"}}]
    }
  end

  test "feature runner should run given scenarios only once" do
    steps = [
      %Steps.When{text: "increment process dictionary"}
    ]

    scenario = %Scenario{name: "test scenario", steps: steps}
    feature = %Feature{name: "test feature", scenarios: [scenario]}
    output = WhiteBread.Outputers.Console.start
    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, output)
    output |> WhiteBread.Outputers.Console.stop

    assert Process.get(:run_count) == 1
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

  when_ "increment process dictionary", fn _state->
    value = (Process.get(:run_count, 0) + 1)
    Process.put(:run_count, value)
  end
end
