defmodule WhiteBread.TestContextPerFeature.MyOtherFeatureBContext do
  use WhiteBread.Context

  subcontext WhiteBread.TestContextPerFeature.OtherFeatureContext

  feature_starting_state fn  ->
    %{feature_state_loaded: :yes}
  end

  scenario_starting_state fn feature_state ->
    feature_state |> Dict.put(:starting_state_loaded, :yes)
  end

  scenario_finalize fn _status, _state ->
    # Do some finalization actions
  end

end

defmodule WhiteBread.TestContextPerFeature.OtherFeatureContext do
  use WhiteBread.Context

  given_ ~r/^(?<anything>.+)$/, fn state, %{anything: _anything} ->
    {:ok, state}
  end

end
