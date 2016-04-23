defmodule WhiteBread.Runners.FeatureRunner do

  alias WhiteBread.Runners.Setup
  alias WhiteBread.Runners.ScenarioRunner
  alias WhiteBread.Runners.ScenarioOutlineRunner

  alias WhiteBread.Gherkin.Elements.Scenario
  alias WhiteBread.Gherkin.Elements.ScenarioOutline

  def run(feature, context, progress_reporter, async: async)
  do
    %{scenarios: scenarios, background_steps: background_steps} = feature

    setup = Setup.new
      |> Map.put(:progress_reporter, progress_reporter)
      |> Map.put(:background_steps, background_steps)

    results = scenarios
      |> run_all_scenarios_for_context(context, setup, async: async)
      |> flatten_any_result_lists

    %{
      successes: results |> Enum.filter(&success?/1),
      failures:  results |> Enum.filter(&failure?/1)
    }
  end

  defp run_all_scenarios_for_context(scenarios, context, setup, async: async) do
    starting_state = apply(context, :feature_state, [])
    setup_with_state = setup
      |> Map.put(:starting_state, starting_state)

    if async do
      scenarios
        |> Enum.map(&run_scenario_async(&1, context, setup_with_state))
        |> Enum.map(&Task.await/1)
    else
      scenarios
        |> Enum.map(&run_scenario(&1, context, setup_with_state))
    end
  end

  defp run_scenario_async(scenario, context, setup) do
    Task.async fn -> run_scenario(scenario, context, setup) end
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
