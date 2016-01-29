defmodule WhiteBread.SubContextTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps
  alias WhiteBread.SubContextTest.ExampleContext, as: ExampleContext

  test "All 3 steps in the sub contexts are returned" do
    assert Enum.count(ExampleContext.get_steps) == 3
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
