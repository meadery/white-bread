defmodule WhiteBread.Runners.Utilities do
  def apply_scenario_starting_state(feature_state, context) do
    apply(context, :scenario_starting_state, [feature_state])
  end
end
