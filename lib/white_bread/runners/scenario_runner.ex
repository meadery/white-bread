defmodule WhiteBread.Runners.ScenarioRunner do

  def run(context, scenario) do
    run_steps(context, scenario.steps, scenario.name)
  end

  def run(context, scenario, [background_steps: background_steps]) do
    all_steps = scenario.steps |> Enum.into background_steps
    run_steps(context, all_steps, scenario.name)
  end

  defp run_steps(context, steps, scenario_name) do
    result = WhiteBread.Runners.run(steps, context)
    case result do
      {:ok, _}   -> {:ok, scenario_name}
      error_data -> {:failed, error_data}
    end
  end

end
