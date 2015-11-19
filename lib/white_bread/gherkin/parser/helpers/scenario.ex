defmodule WhiteBread.Gherkin.Parser.Helpers.Scenario do
  alias WhiteBread.Gherkin.Elements.Scenario
  alias WhiteBread.Gherkin.Elements.ScenarioOutline

  def start_processing_scenario(feature, name, tags) do
    previous_scenarios = feature.scenarios
    new_scenario = %Scenario{name: name, tags: tags}
    {
      %{feature | scenarios: [new_scenario | previous_scenarios]},
      :scenario_steps
    }
  end

  def start_processing_scenario_outline(feature, name, tags) do
    previous_scenarios = feature.scenarios
    new_scenario_outline = %ScenarioOutline{name: name, tags: tags}
    {
      %{feature | scenarios: [new_scenario_outline | previous_scenarios]},
      :scenario_steps
    }
  end

end
