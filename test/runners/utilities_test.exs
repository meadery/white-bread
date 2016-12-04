defmodule ScenarioRunner.UtilitiesTest do
  use ExUnit.Case

  alias WhiteBread.Runners.Utilities

  test "apply_scenario_starting_state calls the context's scenario_starting_state function with the given state" do
    context = quote do
      def scenario_starting_state(state) do
        put_in state[:scenario], :started
      end
    end
    Module.create DummyContext, context, Macro.Env.location(__ENV__)
    state = %{feature: :started}
    start_scenario = Utilities.apply_scenario_starting_state state, DummyContext
    assert start_scenario == %{feature: :started, scenario: :started}
  end
end
