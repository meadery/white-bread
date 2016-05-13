defmodule WhiteBread.ContextBehaviour do
  alias WhiteBread.Gherkin.Elements.Feature
  alias WhiteBread.Gherkin.Elements.Scenario

  @callback get_steps() :: [WhiteBread.Context.StepFunction.t]

  @callback feature_state() :: any

  @callback starting_state(any) :: any

  @callback get_scenario_timeout(Feature.t, Scenario.t) :: number

  @callback finalize(any) :: any
end
