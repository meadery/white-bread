defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.Scenario do
  def run(scenario, context, background_steps) do
    result = WhiteBread.Runners.run(scenario.steps, context, background_steps)
    case result do
      {:ok, _}   -> {:ok, scenario.name}
      error_data -> {:failed, error_data}
    end
  end
end
