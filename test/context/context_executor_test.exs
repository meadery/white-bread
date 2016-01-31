defmodule WhiteBread.Context.ContextExecutorTest do
  use ExUnit.Case

  alias WhiteBread.Context.StepExecutor
  alias WhiteBread.Gherkin.Elements.Steps

  alias WhiteBread.Context.ContextExecutorTest.ExampleContext

  test "Blocks provided with a simple string return ok with the starting state" do
    step = %Steps.Given{text: "I'm running a simple test"}
    state = :old_state
    possible_steps = ExampleContext.get_steps
    assert StepExecutor.execute_step(possible_steps, step, state) == {:ok, state}
  end

  test "functions given with a simple string update and return the state" do
    step = %Steps.When{text: "I pass in some state"}
    state = :old_state
    possible_steps = ExampleContext.get_steps
    assert StepExecutor.execute_step(possible_steps, step, state) == {:ok, [:test_new_state | :old_state]}
  end

  test "steps can be provided with regexes rather than flat strings" do
    state = :old_state
    first_step = %Steps.Given{text: "I'm running a simple bakery"}
    second_step = %Steps.When{text: "I pass in some pie"}

    possible_steps = ExampleContext.get_steps
    assert StepExecutor.execute_step(possible_steps, first_step, state) == {:ok, state}
    assert StepExecutor.execute_step(possible_steps, second_step, state) == {:ok, state}
  end

  test "steps can can use named group capture" do
    state = :old_state
    step = %Steps.Then{text: "my new state should be awesome"}
    possible_steps = ExampleContext.get_steps
    assert StepExecutor.execute_step(possible_steps, step, state) == {:ok, "awesome"}
  end

  test "failing an assert should return a {%ExUnit.AssertionError{}, step, error} tuple" do
    state = :old_state
    step = %Steps.Then{text: "I will always fail"}
    possible_steps = ExampleContext.get_steps
    {result, ^step, _error} = StepExecutor.execute_step(possible_steps, step, state)
    assert result.__struct__ == ExUnit.AssertionError
  end

  test "calling a missing step should return {:missing_step, step, MissingStep}" do
    state = :old_state
    step = %Steps.And{text: "I question if this step exists"}
    possible_steps = ExampleContext.get_steps
    result = StepExecutor.execute_step(possible_steps, step, state)
    assert result == {:missing_step, step,  %WhiteBread.Context.MissingStep{message: "Step not defined"}}
  end

  test "calling a missing step with incorrect values {:no_clause_match, step, FunctionClauseError}" do
    state = :wrong_state
    step = %Steps.When{text: "I require a specific state"}
    possible_steps = ExampleContext.get_steps
    {failure, ^step, _}  = StepExecutor.execute_step(possible_steps, step, state)
    assert failure == :no_clause_match
  end

  test "A step gets table_data passed as an option if available" do
    table_data = [["Hello", "World"]]
    step = %Steps.When{text: "I'm given the table:", table_data: table_data}
    possible_steps = ExampleContext.get_steps
    {:ok, returned_table_data}   = StepExecutor.execute_step(possible_steps, step, :whatever)
    assert table_data == returned_table_data
  end

end

defmodule WhiteBread.Context.ContextExecutorTest.ExampleContext do
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
