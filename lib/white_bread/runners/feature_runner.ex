defmodule WhiteBread.Runners.FeatureRunner do
  alias WhiteBread.Runners.Setup
  alias WhiteBread.Runners.ScenarioRunner
  alias WhiteBread.Runners.ScenarioOutlineRunner

  alias Gherkin.Elements.Scenario
  alias Gherkin.Elements.ScenarioOutline

  def run(feature, context, async: async) do
    setup = Setup.new
      |> Map.put(:background_steps, feature.background_steps)

    results = feature
      |> run_all_scenarios_for_context(context, setup, async: async)

    %{
      successes: results |> Enum.filter(&success?/1),
      failures:  results |> Enum.filter(&failure?/1)
    }
  end

  defp run_all_scenarios_for_context(feature, context, setup, async: async) do
    starting_state = apply(context, :feature_starting_state, [])
    setup_with_state = setup
      |> Map.put(:starting_state, starting_state)

    results = if async do
      feature.scenarios
        |> Enum.map(&run_scenario_async(feature, &1, context, setup_with_state))
        |> Enum.map(&scenario_await/1)
    else
      feature.scenarios
        |> Enum.map(&run_scenario(&1, context, setup_with_state))
    end

    results = results |> flatten_any_result_lists()
    status = if Enum.any?(results, &failure?/1), do: :error, else: :ok
    apply(context, :feature_finalize, [status, starting_state])

    results
  end

  defp run_scenario_async(feature, scenario, context, setup) do
    {
      scenario,
      context.get_scenario_timeout(feature, scenario),
      Task.async fn -> run_scenario(scenario, context, setup) end
    }
  end

  defp scenario_await({scenario, timeout, task}) do
    case Task.yield(task, timeout) do
      {:ok, result}   -> result
      {:exit, reason} -> {scenario, {:failed, reason}}
      nil             -> {scenario, {:failed, :timeout}}
    end
  end

  defp run_scenario(%Scenario{} = scenario, context, setup) do
    result = ScenarioRunner.run(scenario, context, setup)
    {scenario, result}
  end

  defp run_scenario(%ScenarioOutline{} = outline, context, setup) do
    result = ScenarioOutlineRunner.run(outline, context, setup)
    {outline, result}
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

  defp success?({_scenario, {success, _}}), do: success == :ok
  defp failure?({_scenario, {success, _}}), do: success == :failed

end
