defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.Scenario do
  def run(scenario, context, background_steps, starting_state) do
    result = WhiteBread.Runners.run(scenario.steps, context, background_steps, starting_state)
    case result do
      {:ok, _}   -> {:ok, scenario.name}
      error_data -> {:failed, error_data}
    end
  end
end
