defmodule WhiteBread.Formatter.FailedStepTest do
  use ExUnit.Case
  alias WhiteBread.Formatter.FailedStep
  alias WhiteBread.CodeGenerator
  alias WhiteBread.Gherkin.Elements.Steps

  test "Prints out failure with a trace when no matching clause is found" do
    trace = System.stacktrace
    step = %{text: "failing step"}
    failure = {:no_clause_match, step, {%{}, trace}}

    output = FailedStep.text(failure)
    assert output == "unable to match clauses: failing step:\ntrace:\n#{Exception.format_stacktrace trace}"
  end

  test "Prints out regex for a missing step" do
    step = %Steps.When{text: "missing step"}
    failure = {:missing_step, step, :unused}
    code_to_implement = CodeGenerator.Step.regex_code_for_step(step)

    output = FailedStep.text(failure)
    assert output == "undefined step: missing step implement with\n\n" <> code_to_implement
  end

  test "Prints out assestion failing steps" do
    step = %{text: "failing step"}
    assertion_failure = %{message: "this is my assestion message"}
    failure = {:assertion_failure, step, assertion_failure}

    output = FailedStep.text(failure)
    assert output == "failing step: this is my assestion message"
  end

end
