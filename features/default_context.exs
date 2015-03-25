defmodule WhiteBread.Example.DefaultContext do
  use WhiteBread.Context

  subcontext WhiteBread.Example.CoffeeContext
  subcontext WhiteBread.Example.SongContext
  subcontext WhiteBread.Example.TableContext

  feature_starting_state fn  ->
    %{feature_state_loaded: :yes}
  end

  scenario_starting_state fn feature_state ->
    feature_state |> Dict.put(:starting_state_loaded, :yes)
  end

end

defmodule WhiteBread.Example.CoffeeContext do
  use WhiteBread.Context

  given_ ~r/^there are (?<coffees>[0-9]+) coffees left in the machine$/, fn state, %{coffees: coffees} ->
    {:ok, state |> Dict.put(:coffees, coffees)}
  end

  given_ ~r/^I have deposited £(?<pounds>[0-9]+)$/, fn state, %{pounds: pounds} ->
    {:ok, state |> Dict.put(:pounds, pounds)}
  end

  when_ "I press the coffee button", fn
    state = %{coffees: "1"} -> {:ok, state |> Dict.put(:coffees_served, 1)}
    state = %{coffees: "0"} -> {:ok, state |> Dict.put(:coffees_served, 0)}
  end

  then_ "I should be served a coffee", fn state ->
    served_coffees = state |> Dict.get(:coffees_served)
    assert served_coffees == 1
    {:ok, :whatever}
  end

  then_ "I should be frustrated", fn state ->
    served_coffees = state |> Dict.get(:coffees_served)
    assert served_coffees == 0
    {:ok, :whatever}
  end

end

defmodule WhiteBread.Example.SongContext do
  use WhiteBread.Context

  given_ "I want more", fn %{starting_state_loaded: :yes, feature_state_loaded: :yes} ->
    {:ok, :want_more}
  end

  given_ "I had a heart", fn :want_more ->
    {:ok, "have a heart"}
  end

  given_ "I had a voice", fn :want_more ->
    {:ok, "have a voice"}
  end

  then_ "I could love you", fn "have a heart" ->
    {:ok, :love}
  end

  then_ "I would sing", fn "have a voice" ->
    {:ok, :singing}
  end

end

defmodule WhiteBread.Example.TableContext do
  use WhiteBread.Context

  given_ ~r/^the following table:$/,
  &WhiteBread.Example.DefaultContext.TableStuff.load_table/2

  then_ ~r/^everything should be okay.$/,
  &WhiteBread.Example.DefaultContext.TableStuff.all_okay_with_table/1

  given_ ~r/^I am Odin$/, fn _state ->
    {:ok, :when_odin}
  end

  given_ ~r/^I am Thor$/, fn _state ->
    {:ok, :when_thor}
  end

  then_ ~r/^I should have Huginn and Muninn$/, fn :when_odin ->
    {:ok, :when_odin}
  end

  then_ ~r/^I should have Tanngrisnir and Tanngnjóstr$/, fn :when_thor ->
    {:ok, :when_thor}
  end

end

defmodule WhiteBread.Example.DefaultContext.TableStuff do
  import WhiteBread.Helpers

  def load_table(_state, %{table_data: raw_table_data}) do
    table_data = raw_table_data |> index_table_by_first_row

    [%{'Person': first_god}, %{'Person': second_god} | _extra_rows] = table_data
    {:ok, {first_god, second_god}}
  end

  def all_okay_with_table({"Odin", "Thor"} = state) do
    {:ok, state}
  end
end
