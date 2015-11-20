defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.Scenario do
  alias WhiteBread.Outputers.ProgressReporter

  def run(scenario, context, setup) do
    result = WhiteBread.Runners.run(
      scenario.steps,
      context,
      setup
    )
    case result do
      {:ok, _}   -> {:ok, scenario.name}
      error_data -> {:failed, error_data}
    end
      |> output_result(setup.progress_reporter, scenario)
  end

  defp output_result(result_tuple, progress_reporter, scenario) do
    progress_reporter
      |> ProgressReporter.report({:scenario_result, result_tuple, scenario})

    result_tuple
  end
end
