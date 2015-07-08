defmodule WhiteBread.FinalResultPrinterTest do
  use ExUnit.Case
  alias WhiteBread.Formatter

  test "Knows if nothing was run" do
    result = %{
      successes: [],
      failures: []
    }

    output = WhiteBread.FinalResultPrinter.text(result)
    assert output == "Nothing to run."
  end

  test "Indicates zero failures" do
    result = %{
      failures: []
    }

    output = WhiteBread.FinalResultPrinter.text(result)
    assert output == "All features passed."
  end

  test "Prints out failures" do
    trace = System.stacktrace
    step_failure = {:no_clause_match, %{text: "failing step"}, {%{}, trace}}
    result = %{
      failures: [
        {
          %{name: "feature name"},
          %{failures: [
            {%{name: "failing scenario"}, {:failed, step_failure}}
          ]}
        }
      ]
    }
    step_fail_text = Formatter.FailedStep.text(step_failure)

    output = WhiteBread.FinalResultPrinter.text(result)
    assert output == """
    1 scenario failed for feature name
      - failing scenario --> #{step_fail_text}
    """
  end

end
