defmodule WhiteBread.Runners.FeatureRunner do

  def run(%{scenarios: scenarios, background_steps: background_steps} = feature, context, output_pid) do
    results = scenarios
    |> run_all_scenarios_for_context(context, background_steps)
    |> output_results(feature, output_pid)

    %{
      successes: results |> Enum.filter(&is_success/1),
      failures:  results |> Enum.filter(&is_failure/1)
    }
  end

  defp run_all_scenarios_for_context(scenarios, context, background_steps) do
    scenarios |> Stream.map(build_scenario_runner(context, background_steps))
  end

  defp build_scenario_runner(context, background_steps) do
    fn(scenario) -> {scenario, WhiteBread.Runners.ScenarioRunner.run(context, scenario, background_steps: background_steps)} end
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
