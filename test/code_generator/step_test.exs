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

  test "quoted part of a string is replaced with a named group" do
    step_string = "I ask to be \"defined\" thanks"

    expected = %{
      template: "I ask to be \"(?<argument_one>[^\"]+)\" thanks",
      groups: ["argument_one"]
    }
    assert CodeGenerator.named_groups_for_string(step_string) == expected
  end

  test "multiple quoted parts of a string are replaced with a named groups" do
    step_string = "I ask to be \"defined\" with \"something\""

    expected = %{
      template: "I ask to be \"(?<argument_one>[^\"]+)\" with \"(?<argument_two>[^\"]+)\"",
      groups: ["argument_one", "argument_two"]
    }
    assert CodeGenerator.named_groups_for_string(step_string) == expected
  end

  test "Anything in quotes becomes a named group" do
    step = %Steps.When{text: "I ask to be \"defined\""}
    expected_code = """
    when_ ~r/^I ask to be "(?<argument_one>[^"]+)"$/,
    fn state, %{argument_one: _argument_one} ->
      {:ok, state}
    end
    """
    assert CodeGenerator.regex_code_for_step(step) == expected_code
  end

end
