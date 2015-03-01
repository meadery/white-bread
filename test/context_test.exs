defmodule WhiteBread.ContextTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  defmodule ExampleContext do
    use WhiteBread.Context

    given "I'm running a simple test" do
      {:ok, :test_new_state}
    end
  end

  test "Steps can match exact strings" do
    step = %Steps.Given{text: "I'm running a simple test"}
    state = :old_state
    assert ExampleContext.execute_step(step, state) == {:ok, :test_new_state}
  end


end
