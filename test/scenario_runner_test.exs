defmodule WhiteBread.Runners.ScenarioRunnerTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario
  alias WhiteBread.ScenarioRunnerTest.ExampleContext, as: ExampleContext

  test "Returns okay if all the steps pass" do
    steps = [
      %Steps.When{text: "step one"}
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}
    assert {:ok, "test scenario"} == scenario |> WhiteBread.Runners.run(ExampleContext)
  end

  test "Each step passes the updated state to the next" do
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"}
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}
    assert {:ok, "test scenario"} == scenario |> WhiteBread.Runners.run(ExampleContext)
  end

  test "Runs all backround steps first" do
    background_steps = [
      %Steps.When{text: "step one"}
    ]
    steps = [
      %Steps.When{text: "step two"}
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}

    assert {:ok, "test scenario"} == scenario |> WhiteBread.Runners.run(ExampleContext, background_steps)
  end

  test "Fails if the last step is missing" do
    missing_step = %Steps.When{text: "missing step"}
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"},
      missing_step
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}
    {result, {reason, ^missing_step, _}} = scenario |> WhiteBread.Runners.run(ExampleContext)
    assert result == :failed
    assert reason == :missing_step
  end

  test "Fails if a middle step is missing" do
    missing_step = %Steps.When{text: "missing step"}
    steps = [
      %Steps.When{text: "step one"},
      missing_step,
      %Steps.When{text: "step two"}
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}
    {result, {reason, ^missing_step, _}} = scenario |> WhiteBread.Runners.run(ExampleContext)
    assert result == :failed
    assert reason == :missing_step
  end

  test "Fails if the clauses can't be matched for steps" do
    step_two = %Steps.When{text: "step two"}
    steps = [
      %Steps.When{text: "step that blocks step two"},
      step_two
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}
    {result, {reason, ^step_two, _}} = scenario |> WhiteBread.Runners.run(ExampleContext)
    assert result == :failed
    assert reason == :no_clause_match
  end

  test "Fails if a step fails an assertion" do
    assertion_failure_step = %Steps.When{text: "make a failing asserstion"}
    steps = [
      assertion_failure_step,
      %Steps.When{text: "step two"}
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}
    {result, {:assertion_failure, _, _failure}} = scenario |> WhiteBread.Runners.run(ExampleContext)
    assert result == :failed
  end

  test "Fails if a step returns anything but {:ok, state}" do
    failure_step = %Steps.When{text: "I return not okay"}
    expected_step_result = {:no_way, :impossible}

    steps = [
      failure_step,
      %Steps.When{text: "step two"}
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}

    assert {:failed, expected_step_result} == scenario |> WhiteBread.Runners.run(ExampleContext)
  end

  test "Contexts can start with a custom state provied by starting_state method" do
    steps = [
      %Steps.Then{text: "starting state was correct"}
    ]
    scenario = %Scenario{name: "test scenario", steps: steps}

    {result, error} = scenario |> WhiteBread.Runners.run(ExampleContext)
    assert result == :ok
  end

end

defmodule WhiteBread.ScenarioRunnerTest.ExampleContext do
  use WhiteBread.Context

  scenario_starting_state fn global_state ->
    %{starting_state: :yes}
  end

  when_ "step one", fn _state ->
    {:ok, :step_one_complete}
  end

  when_ "step that blocks step two", fn _state ->
    {:ok, :unexpected_state}
  end

  when_ "step two", fn :step_one_complete ->
    {:ok, :step_two_complete}
  end

  when_ "make a failing asserstion", fn _state ->
    assert 1 == 0
    {:ok, :impossible}
  end

  when_ "I return not okay", fn _state ->
    {:no_way, :impossible}
  end

  then_ "starting state was correct", fn %{starting_state: :yes} = state ->
    {:ok, state}
  end

end
