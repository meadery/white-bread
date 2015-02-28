defmodule WhiteBread.Gherkin.Parser.GenericLine do
  require Logger
  alias WhiteBread.Gherkin.Parser.Steps, as: StepsParser
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario

  import String, only: [rstrip: 1, rstrip: 2, lstrip: 1]

  def process_line("Feature: " <> name = line, {feature, :start}) do
    log line
    {%{feature | name: rstrip(name)}, :feature_description}
  end

  def process_line("Scenario: " <> name = line, {feature = %{scenarios: previous_scenarios}, _}) do
    log line
    new_scenario = %Scenario{name: name}
    {%{feature | scenarios: [new_scenario | previous_scenarios]}, :scenario_steps}
  end

  def process_line(line, {feature = %{description: current_description}, :feature_description}) do
    log line
    {%{feature | description: current_description <> line <> "\n"}, :feature_description}
  end

  def process_line(line, {feature = %{scenarios: [scenario | rest]}, :scenario_steps}) do
    log line
    updated_scenario = StepsParser.add_step_to_scenario(scenario, line)
    {%{feature | scenarios: [updated_scenario | rest]}, :scenario_steps}
  end

  def process_line(line, state) do
    log line
    state
  end

  defp log(line) do
    Logger.debug("Parsing line: #{line}")
  end

end
