defmodule WhiteBread.SubContextTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps
  alias WhiteBread.SubContextTest.ExampleContext, as: ExampleContext

  test "Blocks provided with a simple string return ok with the starting state" do
    step = %Steps.Given{text: "I'm running a simple test"}
    state = :old_state
    assert ExampleContext.execute_step(step, state) == {:ok, state}
  end

  test "steps can be provided with regexes rather than flat strings" do
    state = :old_state
    first_step = %Steps.Given{text: "I'm running a simple bakery"}
    second_step = %Steps.When{text: "I pass in some pie"}

    assert ExampleContext.execute_step(first_step, state) == {:ok, state}
    assert ExampleContext.execute_step(second_step, state) == {:ok, state}
  end

end

defmodule WhiteBread.SubContextTest.ExampleContext do
  use WhiteBread.Context

  subcontext WhiteBread.SubContextTest.SubExampleContext.One
  subcontext WhiteBread.SubContextTest.SubExampleContext.Two

end


defmodule WhiteBread.SubContextTest.SubExampleContext.One do
  use WhiteBread.Context

  given_ "I'm running a simple test" do
    # Nothing happening here
  end
end

defmodule WhiteBread.SubContextTest.SubExampleContext.Two do
  use WhiteBread.Context

  given_ ~r/I'm running a simple [A-Za-z]+/ do
    # nothing happening here
  end

  when_ ~r/I pass in some [A-Za-z]+/, fn state ->
    {:ok, state}
  end
end
