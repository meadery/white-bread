defmodule WhiteBread.FinalResultPrinterTest do
  use ExUnit.Case

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
    result = %{
      failures: [
        {
          %{name: "feature name"},
          %{failures: [
            {%{name: "failing scenario"}, {:failed, {:no_clause_match, %{text: "failing step"}, {%{}, trace}}}}
          ]}
        }
      ]
    }

    output = WhiteBread.FinalResultPrinter.text(result)
    assert output == """
    1 scenario failed for feature name
      - failing scenario --> unable to match clauses: failing step:
     trace:
     #{Exception.format_stacktrace trace}
    """
  end

end
