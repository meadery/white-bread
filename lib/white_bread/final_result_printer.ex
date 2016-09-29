defmodule WhiteBread.FinalResultPrinter do
  alias WhiteBread.Formatter.FailedStep
  alias WhiteBread.Outputers.Style

  def puts(result) do
    IO.puts result
  end

  def text(_, step_helper \\ FailedStep)

  def text(%{successes: [], failures: []}, _step_helper) do
    "Nothing to run."
  end

  def text(%{failures: []}, _step_helper) do
    "All features passed."
  end

  def text(%{failures: failures}, step_helper) do
    failures
      |> Enum.map(&failing_feature_text(&1, step_helper))
      |> Enum.join("\n")
      |> add_newline
  end

  defp failing_feature_text(failing_feature, step_helper) do
    {feature, %{failures: failing_scenarios}} = failing_feature
    scenerios_text = failing_scenarios
      |> Enum.map(&failing_scenerio_text(&1, step_helper))
      |> Enum.join("\n")

    failing_count = Enum.count(failing_scenarios)
    Style.failed "#{failing_count} scenario failed for"
    <> " #{feature.name}\n"
    <> scenerios_text

  end

  defp failing_scenerio_text(scenario_faliure, step_helper) do
    {failing_scenario, {:failed, failure}} = scenario_faliure
    reason = failure |> get_fail_reason(step_helper)
    "  - #{failing_scenario.name} --> #{reason}"
  end

  defp get_fail_reason({failure_type, failing_step, fail_data}, step_helper) do
    step_helper.text(failure_type, failing_step, fail_data)
  end

  defp get_fail_reason(:timeout, _), do: "Scenario timed out waiting for result"
  defp get_fail_reason(:no_examples_given, _), do: "Scenario Outline needs at least one example"

  defp get_fail_reason(_, _), do: "Ended in a not okay state"

  defp add_newline(string), do: string <> "\n"
end
