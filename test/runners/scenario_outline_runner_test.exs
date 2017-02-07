defmodule WhiteBread.Runners.ScenarioOutlineRunnerTest do
  use ExUnit.Case
  alias Gherkin.Elements.Steps, as: Steps
  alias Gherkin.Elements.ScenarioOutline, as: ScenarioOutline
  alias WhiteBread.ScenarioOutlineRunnerTest.ExampleContext, as: ExampleContext

  alias WhiteBread.Runners.ScenarioOutlineRunner

  test "Inserts the expexted text and runs" do
    steps = [
      %Steps.When{text: "step <number_one>"},
      %Steps.When{text: "step <number_two>"}
    ]
    examples = [
      ["number_one", "number_two"],
      ["one",        "one"],
      ["one",        "two"]
    ]
    scenario_outline = %ScenarioOutline{name: "test scenario", steps: steps, examples: examples}

    expected_two_successes = [
      {:ok, "test scenario"},
      {:ok, "test scenario"}
    ]
    assert expected_two_successes == scenario_outline |> ScenarioOutlineRunner.run(ExampleContext)
  end

  test "Returns failures for any example" do
    steps = [
      %Steps.When{text: "step <number_one>"},
      %Steps.When{text: "step <number_two>"}
    ]
    examples = [
      ["number_one", "number_two"],
      ["one",        "two"],
      ["two",        "one"]
    ]
    scenario_outline = %ScenarioOutline{name: "test scenario", steps: steps, examples: examples}

    [{:ok, "test scenario"}, {expected_result, _failure_data}
    ] = scenario_outline |> ScenarioOutlineRunner.run(ExampleContext)


    assert expected_result == :failed
  end

  test "Returns failure if no examples are provided" do
    steps = [
      %Steps.When{text: "step <number_one>"},
      %Steps.When{text: "step <number_two>"}
    ]
    examples = []

    scenario_outline = %ScenarioOutline{name: "test scenario", steps: steps, examples: examples}

    [{expected_result, failure_data}] = scenario_outline |> ScenarioOutlineRunner.run(ExampleContext)

    assert expected_result == :failed
    assert failure_data == :no_examples_given
  end

end

defmodule WhiteBread.ScenarioOutlineRunnerTest.ExampleContext do
  use WhiteBread.Context

  scenario_starting_state fn _global_state ->
    %{starting_state: :yes}
  end

  when_ "step one", fn _state ->
    {:ok, :step_one_complete}
  end

  when_ "step two", fn :step_one_complete ->
    {:ok, :step_two_complete}
  end

end
