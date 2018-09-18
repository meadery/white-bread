defmodule WhiteBread.TestContextPerFeature.MyOtherFeatureBContext do
  use WhiteBread.Context

  import_steps_from WhiteBread.TestContextPerFeature.OtherFeatureContext

  feature_starting_state fn  ->
    %{feature_state_loaded: :yes}
  end

  scenario_starting_state fn feature_state ->
    feature_state |> Map.put(:starting_state_loaded, :yes)
  end

  scenario_finalize fn _status, state ->
    state
  end

end

defmodule WhiteBread.TestContextPerFeature.OtherFeatureContext do
  use WhiteBread.Context

  def_given ~r/^(?<anything>.+)$/, fn state, %{anything: _anything} ->
    {:ok, state}
  end

end
