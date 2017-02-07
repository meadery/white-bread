defmodule WhiteBread.Runners.FeatureRunnerTest do
  use ExUnit.Case
  alias Gherkin.Elements.Steps, as: Steps
  alias Gherkin.Elements.Feature, as: Feature
  alias Gherkin.Elements.Scenario, as: Scenario
  alias WhiteBread.FeatureRunnerTest.ExampleContext, as: ExampleContext

  setup_all do
    {:ok, o} = WhiteBread.EventManager.add_handler(WhiteBread.Outputers.Console, [])
    {:ok, outputer: o}
  end

  test "feature runner should return succesful scenarios" do
    steps = [
      %Steps.When{text: "step one"},
      %Steps.When{text: "step two"}
    ]

    scenario = %Scenario{name: "test scenario", steps: steps}
    feature = %Feature{name: "test feature", scenarios: [scenario]}

    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, async: false)

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

    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, async: false)

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

    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, async: false)

    assert result == %{
      failures: [],
      successes: [{scenario, {:ok, "test scenario"}}]
    }
  end

  test "timed out scenarios should be failed" do
    steps = [
      %Steps.When{text: "I take too long to execute"}
    ]

    scenario = %Scenario{name: "slow scenario", steps: steps}
    feature = %Feature{name: "test feature", scenarios: [scenario]}

    result = WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, async: true)

    assert result == %{
      failures: [{scenario, {:failed, :timeout}}],
      successes: []
    }
  end

  test "feature runner should run given scenarios only once" do

    WhiteBread.FeatureRunnerTest.GlobalCounter.start_link

    steps = [
      %Steps.When{text: "increment global counter"}
    ]

    scenario = %Scenario{name: "test scenario", steps: steps}
    feature = %Feature{name: "test feature", scenarios: [scenario]}

    WhiteBread.Runners.FeatureRunner.run(feature, ExampleContext, async: false)

    count_at_end = WhiteBread.FeatureRunnerTest.GlobalCounter.get

    assert count_at_end == 1
  end
end

defmodule WhiteBread.FeatureRunnerTest.ExampleContext do
  use WhiteBread.Context
  alias WhiteBread.FeatureRunnerTest.GlobalCounter

  scenario_timeouts fn _feature, scenario ->
    case scenario.name do
      "slow scenario" -> 1
      _               -> 5000
    end
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

  when_ "make a failing assertion", fn _state ->
    assert 1 == 0
    {:ok, :impossible}
  end

  when_ "I take too long to execute", fn _state ->
    :timer.sleep(1000 * 60)
    {:ok, :slow}
  end

  when_ "increment global counter", fn _state->
    GlobalCounter.increment
  end
end

defmodule WhiteBread.FeatureRunnerTest.GlobalCounter do

  def start_link do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, fn x -> x end)
  end

  def increment() do
    Agent.update(__MODULE__, fn x -> x + 1 end)
  end
end
