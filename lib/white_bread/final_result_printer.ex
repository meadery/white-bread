defmodule WhiteBread.FinalResultPrinter do
  alias WhiteBread.Formatter.FailedStep

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
    text = failures
      |> Enum.map(&failing_feature_text(&1, step_helper))
      |> Enum.join("\n")
    text <> "\n"
  end

  defp failing_feature_text(failing_feature, step_helper) do
    {feature, %{failures: failing_scenarios}} = failing_feature
    scenerios_text = failing_scenarios
      |> Enum.map(&failing_scenerio_text(&1, step_helper))
      |> Enum.join("\n")

    failing_count = Enum.count(failing_scenarios)
    "#{failing_count} scenario failed for #{feature.name}\n" <> scenerios_text
  end

  defp failing_scenerio_text(scenario_faliure, step_helper) do
    {failing_scenario, {:failed, failure}} = scenario_faliure
    {failure_type, failing_step, fail_data} = failure
    reason = step_helper.text(failure_type, failing_step, fail_data)
    "  - #{failing_scenario.name} --> #{reason}"
  end

end
