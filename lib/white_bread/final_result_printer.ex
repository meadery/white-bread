defmodule WhiteBread.FinalResultPrinter do

  def puts(result) do
    IO.puts result
  end

  def text(%{successes: [], failures: []}) do
    "Nothing to run."
  end

  def text(%{failures: []}) do
    "All features passed."
  end

  def text(%{failures: failures}) do
    text = failures
    |> Enum.map(&failing_feature_text/1)
    |> Enum.join("\n")
    text <> "\n"
  end

  defp failing_feature_text({feature, %{failures: failing_scenarios}}) do

    scenerios_text = failing_scenarios
    |> Enum.map(&failing_scenerio_text/1)
    |> Enum.join("\n")

    failing_count = Enum.count(failing_scenarios)
    "#{failing_count} scenario failed for #{feature.name}\n" <> scenerios_text
  end

  defp failing_scenerio_text({failing_scenario, {:failed, failure}}) do
    reason = failure_reason_text(failure)
    "  - #{failing_scenario.name} --> #{reason}"
  end

  defp failure_reason_text({:missing_step, %{text: step_text} = step, _error}) do
    code_to_implement = WhiteBread.CodeGenerator.Step.regex_code_for_step(step)
    "undefined step: #{step_text} implement with\n\n" <> code_to_implement
  end
  defp failure_reason_text({:no_clause_match, %{text: step_text}, {clause_match_error, stacktrace}}) do
    trace_message = Exception.format_stacktrace(stacktrace)
    "unable to match clauses: #{step_text}:\n trace:\n #{trace_message}"
  end
  defp failure_reason_text({:assertion_failure, %{text: step_text}, assertion_failure}) do
    %{message: assestion_message} = assertion_failure
    "#{step_text}: #{assestion_message}"
  end

end
