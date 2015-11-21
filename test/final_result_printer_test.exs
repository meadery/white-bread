defmodule WhiteBread.FinalResultPrinterTest do
  use ExUnit.Case

  defmodule MockStepFailure do
    def text(_,_,_), do: "STEP_FAILURE_TEXT"
  end

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

    output = WhiteBread.FinalResultPrinter.text(result, MockStepFailure)
    assert output == """
    1 scenario failed for feature name
      - failing scenario --> STEP_FAILURE_TEXT
    """
  end

end
