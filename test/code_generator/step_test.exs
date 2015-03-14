defmodule WhiteBread.CodeGenerator.StepTest do
  use ExUnit.Case
  alias WhiteBread.CodeGenerator.Step, as: CodeGenerator
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  test "Returns a regular expression step" do
    step = %Steps.When{text: "I ask to be defined"}
    expected_code = """
    when_ ~r/^I ask to be defined$/, fn state ->
      {:ok, state}
    end
    """
    assert CodeGenerator.regex_code_for_step(step) == expected_code
  end

end
