defmodule WhiteBread.Runners.FeatureRunner do

  def run(%{scenarios: scenarios, background_steps: background_steps} = feature, context, output_pid) do
    results = scenarios
    |> add_background_to_all_scenarios(background_steps)
    |> run_all_scenarios_for_context(context)
    |> remove_background_from_scenarios
    |> output_results(feature, output_pid)

    %{
      successes: results |> Enum.filter(&is_success/1),
      failures:  results |> Enum.filter(&is_failure/1)
    }
  end

  defp add_background_to_all_scenarios(scenarios, background_steps) do
    scenarios |> Stream.map(
      fn(scenario) -> %WhiteBread.ScenarioAndBackground{scenario: scenario, background_steps: background_steps} end
    )
  end

  defp run_all_scenarios_for_context(scenarios, context) do
    scenarios
    |> Stream.map(fn(scenario_and_background) -> {scenario_and_background, WhiteBread.Runners.run(scenario_and_background, context)} end)
  end

  defp remove_background_from_scenarios(scenarios) do
    scenarios
    |> Stream.map(fn({scenario_and_background, result}) -> {scenario_and_background.scenario, result} end)
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
