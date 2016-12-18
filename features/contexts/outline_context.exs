defmodule WhiteBread.Example.OutlineContext do
  use WhiteBread.Context

  import_steps_from WhiteBread.Example.OutlineContext.AdditionalStateSteps
  import_steps_from WhiteBread.Example.OutlineContext.StringSteps

  feature_starting_state fn  ->
    %{feature_state_loaded: :yes}
  end

  scenario_starting_state fn feature_state ->
    feature_state
    |> Dict.put(:starting_state_loaded, :yes)
    |> Dict.put(:additional_state, [])
  end

  scenario_finalize fn _state ->
    # Do some finalization actions
  end

  given_ ~r/^a scenario outline$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^it should load the scenario starting state$/, fn state ->
    IO.inspect state
    assert state[:starting_state_loaded] == :yes
    {:ok, state}
  end
end

defmodule WhiteBread.Example.OutlineContext.AdditionalStateSteps do
  use WhiteBread.Context

  given_ ~r/^some additional state "(?<new_item>[^"]+)"$/, fn state, %{new_item: new_item} ->
    {_, new_state} = get_and_update_in state[:additional_state], &{&1, [new_item|&1]}
    {:ok, new_state}
  end

  then_ ~r/^it should have only the additional state "(?<item>[^"]+)"$/, fn state, %{item: item} ->
    assert state[:additional_state] == [item]
    {:ok, state}
  end
end

defmodule WhiteBread.Example.OutlineContext.StringSteps do
  import String, only: [contains?: 2]

  use WhiteBread.Context

  given_ ~r/^the string "(?<string>[^"]+)"/, fn state, %{string: string} ->
    {:ok, put_in(state[:string], string)}
  end

  then_ ~r/^the string should contain "(?<substring>[^"]+)"$/, fn state, %{substring: substring} ->
    assert state[:string] |> contains?(substring)
    {:ok, state}
  end
end
