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

end

defmodule WhiteBread.ScenarioRunnerTest.ExampleContext do
  use WhiteBread.Context

  when_ "step one", fn _state ->
    {:ok, :step_one_complete}
  end

  when_ "step two", fn :step_one_complete ->
    {:ok, :step_two_complete}
  end

end
