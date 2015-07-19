defmodule WhiteBread.Runners.FeatureRunner do

  def run(feature, context, output_pid) do
    %{scenarios: scenarios, background_steps: background_steps} = feature
    results = scenarios
      |> run_all_scenarios_for_context(context, background_steps)
      |> flatten_any_result_lists
      |> output_results(feature, output_pid)

    %{
      successes: results |> Enum.filter(&is_success/1),
      failures:  results |> Enum.filter(&is_failure/1)
    }
  end

  defp run_all_scenarios_for_context(scenarios, context, background_steps) do
    feature_starting_state = apply(context, :feature_state, [])
    run = fn(scenario) ->
      result = run(scenario, context, background_steps, feature_starting_state)
      {scenario, result}
    end
    scenarios |> Stream.map(run)
  end

  defp flatten_any_result_lists(results) do
    flatten = fn
      ({scenario, results}) when is_list(results) ->
        results |> Enum.map(fn(result) -> {scenario, result} end)
      (single) ->
        [single]
    end
    results |> Stream.flat_map(flatten)
  end

  defp output_results(results, feature, output_pid) do
    send_results = fn({scenario, result}) ->
      send(output_pid, {:scenario_result, result, scenario, feature})
    end
    results
      |> Stream.each(send_results)
      |> Stream.run

    results
  end

  defp is_success({_scenario, {success, _}}) do
    success == :ok
  end

  defp is_failure({_scenario, {success, _}}) do
    success == :failed
  end

  defp run(scenario, context, background_steps, starting_state) do
    scenario
      |> WhiteBread.Runners.run(context, background_steps, starting_state)
  end

end
