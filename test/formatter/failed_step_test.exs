defmodule WhiteBread.Formatter.FailedStepTest do
  use ExUnit.Case
  alias WhiteBread.Formatter.FailedStep
  alias WhiteBread.CodeGenerator
  alias WhiteBread.Gherkin.Elements.Steps

  test "Prints out failure with a trace when no matching clause is found" do
    trace = System.stacktrace
    step = %{text: "failing step"}

    output = FailedStep.text(:no_clause_match, step, {%{}, trace})
    assert output == "\e[31munable to match clauses: failing step:\ntrace:\n#{Exception.format_stacktrace trace}\e[0m"
  end

  test "Prints out regex for a missing step" do
    step = %Steps.When{text: "missing step"}
    code_to_implement = CodeGenerator.Step.regex_code_for_step(step)

    output = FailedStep.text(:missing_step, step, :unused)
    assert output == "\e[34mundefined step: missing step implement with\n\n" <> code_to_implement <> "\e[0m"
  end

  test "Prints out assestion failing steps" do
    step = %{text: "failing step"}
    assertion_failure = %ExUnit.AssertionError{
      message: "this is my assertion message"
    }

    output = FailedStep.text(assertion_failure, step, assertion_failure)
    assert output == "failing step: this is my assertion message"
  end

  test "Prints out other failing steps" do
    step = %{text: "failing step"}
    exception = %RuntimeError{message: "exception message"}

    stacktrace = [{Module, :failure, 0, [{:file, "somefile"}, {:line, 10}]}]

    output = FailedStep.text(:other_failure, step, {exception, stacktrace})
    assert output == "execution failure: #{step.text}:\n\e[33mException: #{Exception.message exception}: \n#{Exception.format_stacktrace stacktrace}\e[0m"
  end
end
