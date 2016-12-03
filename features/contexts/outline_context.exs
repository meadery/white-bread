defmodule WhiteBread.Example.OutlineContext do
  import String, only: [contains?: 2]

  use WhiteBread.Context

  feature_starting_state fn  ->
    %{feature_state_loaded: :yes}
  end

  scenario_starting_state fn feature_state ->
    feature_state |> Dict.put(:starting_state_loaded, :yes)
  end

  scenario_finalize fn _state ->
    # Do some finalization actions
  end

  given_ ~r/^the string "(?<string>[^"]+)"/, fn state, %{string: string} ->
    {:ok, put_in(state[:string], string)}
  end

  then_ ~r/^the string should contain "(?<substring>[^"]+)"$/, fn state, %{substring: substring} ->
    assert state[:string] |> contains?(substring)
    {:ok, state}
  end
end
