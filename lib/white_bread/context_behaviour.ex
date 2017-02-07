defmodule WhiteBread.ContextBehaviour do
  alias Gherkin.Elements.Feature
  alias Gherkin.Elements.Scenario

  @callback get_steps() :: [WhiteBread.Context.StepFunction.t]

  @callback feature_starting_state() :: any

  @callback feature_finalize(atom, any) :: any

  @callback scenario_starting_state(any) :: any

  @callback scenario_finalize(atom, any) :: any

  @callback get_scenario_timeout(Feature.t, Scenario.t) :: number

end
