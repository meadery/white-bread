defmodule WhiteBread.Example.AlternateContext do
  use WhiteBread.Context

  subcontext WhiteBread.Example.AnythingGoesContext

  feature_starting_state fn  ->
    %{feature_state_loaded: :yes}
  end

  scenario_starting_state fn feature_state ->
    feature_state |> Dict.put(:starting_state_loaded, :yes)
  end

  scenario_finalize fn _state ->
    # Do some finalization actions
  end

end

defmodule WhiteBread.Example.AnythingGoesContext do
  use WhiteBread.Context

  given_ ~r/^(?<anything>.+)$/, fn state, %{anything: _anything} ->
    {:ok, state}
  end

end
