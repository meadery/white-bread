defmodule WhiteBread.ContextTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  defmodule ExampleContext do
    use WhiteBread.Context

    given_ "I'm running a simple test" do
      # Nothing happening here
    end

    given_ "I pass in some state", fn state ->
      {:ok, [:test_new_state | state]}
    end

  end

  test "Blocks provided with a simple string return ok with the starting state" do
    step = %Steps.Given{text: "I'm running a simple test"}
    state = :old_state
    assert ExampleContext.execute_step(step, state) == {:ok, state}
  end

  test "functions given with a simple string update and return the state" do
    step = %Steps.When{text: "I pass in some state"}
    state = :old_state
    assert ExampleContext.execute_step(step, state) == {:ok, [:test_new_state | :old_state]}
  end


end
