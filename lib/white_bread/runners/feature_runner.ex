defmodule WhiteBread.Runners.FeatureRunner do
  alias WhiteBread.Runners.Setup
  alias WhiteBread.Runners

  def run(feature, context, output_pid) do
    %{scenarios: scenarios, background_steps: background_steps} = feature
    results = scenarios
      |> run_all_scenarios_for_context(context, background_steps)
      |> flatten_any_result_lists
      |> output_results(output_pid)

    %{
      successes: results |> Enum.filter(&success?/1),
      failures:  results |> Enum.filter(&failure?/1)
    }
  end

  defp run_all_scenarios_for_context(scenarios, context, background_steps) do
    starting_state = apply(context, :feature_state, [])
    scenarios
      |> Enum.map(&run_scenario(&1,context, background_steps, starting_state))
  end

  defp run_scenario(scenario,context, background_steps, starting_state) do
    result = run(scenario, context, background_steps, starting_state)
    {scenario, result}
  end

  defp flatten_any_result_lists(results) do
    flatten = fn
      ({scenario, results}) when is_list(results) ->
        results |> Enum.map(fn(result) -> {scenario, result} end)
      (single) ->
        [single]
    end
    results |> Enum.flat_map(flatten)
  end

  defp output_results(results, output_pid) do
    send_results = fn({scenario, result}) ->
      send(output_pid, {:scenario_result, result, scenario})
    end

    results |> Enum.each(send_results)

    results
  end

  defp success?({_scenario, {success, _}}), do: success == :ok
  defp failure?({_scenario, {success, _}}), do: success == :failed

  defp run(scenario, context, background_steps, starting_state) do
    setup = Setup.new(background_steps: background_steps, state: starting_state)
    scenario |> Runners.run(context, setup)
  end

end
