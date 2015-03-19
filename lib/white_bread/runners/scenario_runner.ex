defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.Scenario do
  def run(scenario, context) do
    result = WhiteBread.Runners.run(scenario.steps, context)
    case result do
      {:ok, _}   -> {:ok, scenario.name}
      error_data -> {:failed, error_data}
    end
  end
end
