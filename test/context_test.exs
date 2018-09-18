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

  def_given "I'm running a simple test" do
    # Nothing happening here
  end

  def_when "I pass in some state", fn state ->
    {:ok, [:test_new_state | state]}
  end

  def_given ~r/I'm running a simple [A-Za-z]+/ do
    # nothing happening here
  end

  def_when ~r/I pass in some [A-Za-z]+/, fn state ->
    {:ok, state}
  end

  def_when "I require a specific state", fn :specific_state ->
    {:ok, :new_state}
  end

  def_then ~r/my new state should be (?<new_state>[A-Za-z]+)/, fn _state, %{new_state: new_state} ->
    {:ok, new_state}
  end

  def_when ~r/I'm given the table:/, fn _state, %{table_data: table_data} ->
    {:ok, table_data}
  end

  def_then "I will always fail" do
    assert 1 == 0
  end
end
