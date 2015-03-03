defmodule WhiteBread.FeatureRunner do

  def run(context, %{scenarios: scenarios} = feature, output_pid) do
    results = scenarios
    |> run_all_scenarios_for_context(context)
    |> output_results(feature, output_pid)

    %{
      successes: results |> Enum.filter(&is_success/1),
      failures:  results |> Enum.filter(&is_failure/1)
    }
  end

  defp run_all_scenarios_for_context(scenarios, context) do
    scenarios |> Stream.map(context_scenario_runner(context))
  end

  defp context_scenario_runner(context) do
    fn(scenario) -> {scenario, WhiteBread.ScenarioRunner.run(context, scenario)} end
  end

  defp output_results(results, feature, output_pid) do
    results
    |> Stream.each(fn({scenario, result})  -> send(output_pid, {:scenario_result, result, scenario, feature}) end)
    |> Stream.run

    results
  end

  defp is_success({_scenario, {success, _}}) do
    success == :ok
  end

  defp is_failure({_scenario, {success, _}}) do
    success == :failed
  end
end
