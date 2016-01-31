defmodule WhiteBread.ContextTest do
  use ExUnit.Case

  test "ExampleContext has 8 steps" do
     count = WhiteBread.ContextTest.ExampleContext.get_steps
      |> Enum.count
      assert count == 8
  end

end

defmodule WhiteBread.ContextTest.ExampleContext do
  use WhiteBread.Context

  given_ "I'm running a simple test" do
    # Nothing happening here
  end

  when_ "I pass in some state", fn state ->
    {:ok, [:test_new_state | state]}
  end

  given_ ~r/I'm running a simple [A-Za-z]+/ do
    # nothing happening here
  end

  when_ ~r/I pass in some [A-Za-z]+/, fn state ->
    {:ok, state}
  end

  when_ "I require a specific state", fn :specific_state ->
    {:ok, :new_state}
  end

  then_ ~r/my new state should be (?<new_state>[A-Za-z]+)/, fn _state, %{new_state: new_state} ->
    {:ok, new_state}
  end

  when_ ~r/I'm given the table:/, fn _state, %{table_data: table_data} ->
    {:ok, table_data}
  end

  then_ "I will always fail" do
    assert 1 == 0
  end
end
