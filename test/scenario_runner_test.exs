defmodule WhiteBread.ScenarioRunnerTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps
  alias WhiteBread.ScenarioRunnerTest.ExampleContext, as: ExampleContext

  test "Returns okay if all the steps pass" do
    steps = [
      %Steps.When{text: "step one"}
    ]
    scenario = %{name: "test scenario", steps: steps}
    assert {:ok, "test scenario"} == ExampleContext |> WhiteBread.ScenarioRunner.run(scenario)
  end

  test "Each step passes the updated state to the next" do
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"}
    ]
    scenario = %{name: "test scenario", steps: steps}
    assert {:ok, "test scenario"} == ExampleContext |> WhiteBread.ScenarioRunner.run(scenario)
  end

  test "Fails if the last step is missing" do
    missing_step = %Steps.When{text: "missing step"}
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"},
      missing_step
    ]
    scenario = %{name: "test scenario", steps: steps}
    assert {:failed, {:missing_step, missing_step}} == ExampleContext |> WhiteBread.ScenarioRunner.run(scenario)
  end

  test "Fails if a middle step is missing" do
    missing_step = %Steps.When{text: "missing step"}
    steps = [
      %Steps.When{text: "step one"},
      missing_step,
      %Steps.When{text: "step two"}
    ]
    scenario = %{name: "test scenario", steps: steps}
    assert {:failed, {:missing_step, missing_step}} == ExampleContext |> WhiteBread.ScenarioRunner.run(scenario)
  end

  test "Fails if the clauses can't be matched for steps" do
    step_two = %Steps.When{text: "step two"}
    steps = [
      %Steps.When{text: "step that blocks step two"},
      step_two
    ]
    scenario = %{name: "test scenario", steps: steps}
    assert {:failed, {:no_clause_match, step_two}} == ExampleContext |> WhiteBread.ScenarioRunner.run(scenario)
  end

  test "Fails if a step fails an assertion" do
    assertion_failure_step = %Steps.When{text: "make a failing assestion"}
    steps = [
      assertion_failure_step,
      %Steps.When{text: "step two"}
    ]
    scenario = %{name: "test scenario", steps: steps}
    {result, {:assertion_failure, ^assertion_failure_step, _failure}} = ExampleContext |> WhiteBread.ScenarioRunner.run(scenario)
    assert result == :failed
  end
end

defmodule WhiteBread.ScenarioRunnerTest.ExampleContext do
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
