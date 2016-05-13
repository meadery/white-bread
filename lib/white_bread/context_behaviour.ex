defmodule WhiteBread.ContextBehaviour do

  @callback get_steps() :: [WhiteBread.Context.StepFunction.t]

  @callback feature_state() :: any

  @callback starting_state(any) :: any

  @callback get_scenario_timeout(String.t, String.t) :: any

  @callback finalize(any) :: any
end
