defimpl WhiteBread.Runners, for: WhiteBread.ScenarioAndBackground do
  def run(scenario_and_background, context) do
    all_steps = scenario_and_background.scenario.steps
    |> Enum.into scenario_and_background.background_steps

    result = WhiteBread.Runners.run(all_steps, context)
    case result do
      {:ok, _}   -> {:ok, scenario_and_background.scenario.name}
      error_data -> {:failed, error_data}
    end
  end
end
