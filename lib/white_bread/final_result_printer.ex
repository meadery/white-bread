defmodule WhiteBread.FinalResultPrinter do
  alias WhiteBread.Formatter.FailedStep

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
    reason = FailedStep.text(failure)
    "  - #{failing_scenario.name} --> #{reason}"
  end

end
