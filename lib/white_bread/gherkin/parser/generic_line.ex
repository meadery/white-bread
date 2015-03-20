defmodule WhiteBread.Gherkin.Parser.GenericLine do
  require Logger
  alias WhiteBread.Gherkin.Parser.Steps, as: StepsParser
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario
  alias WhiteBread.Gherkin.Elements.ScenarioOutline, as: ScenarioOutline

  import String, only: [rstrip: 1, rstrip: 2, lstrip: 1]

  def process_line("", state) do
    Logger.debug("Parser skipping blank line")
    state
  end

  def process_line("@" <> line, {feature, _parser_state}) do
    log line
    tags = line
    |> String.split("@", trim: true)
    |> Enum.map(&String.strip/1)
    {feature, %{tags: tags}}
  end

  def process_line("Feature: " <> name = line, {feature, parser_state}) do
    feature_tags = tags_from_state(parser_state)
    log line
    {%{feature | name: rstrip(name), tags: feature_tags}, :feature_description}
  end

  def process_line("Background:" <> _ = line, {feature, _} ) do
    log line
    {feature, :background_steps}
  end

  def process_line("Examples:" <> _ = line, {feature, _} ) do
    log line
    {feature, :scenario_outline_example}
  end

  def process_line("Scenario: " <> name = line, {feature = %{scenarios: previous_scenarios}, parser_state}) do
    log line
    scenario_tags = tags_from_state(parser_state)
    new_scenario = %Scenario{name: name, tags: scenario_tags}
    {%{feature | scenarios: [new_scenario | previous_scenarios]}, :scenario_steps}
  end

  def process_line("Scenario Outline: " <> name = line, {feature = %{scenarios: previous_scenarios}, parser_state}) do
    log line
    scenario_tags = tags_from_state(parser_state)
    new_scenario_outline = %ScenarioOutline{name: name, tags: scenario_tags}
    {%{feature | scenarios: [new_scenario_outline | previous_scenarios]}, :scenario_steps}
  end

  # Tables as part of a step
  def process_line("|" <> line, {feature = %{scenarios: [scenario | rest]}, :scenario_steps}) do
    log line

    table_row = table_line_to_columns(line)

    updated_scenario = scenario |> StepsParser.add_table_row_to_last_step(table_row)
    {%{feature | scenarios: [updated_scenario | rest]}, :scenario_steps}
  end

  # Tables as part of an example for a scenario
  def process_line("|" <> line, {feature = %{scenarios: [scenario_outline | rest]}, :scenario_outline_example}) do
    log line

    table_row = table_line_to_columns(line)
    update_examples = scenario_outline.examples ++ [table_row]
    updated_scenario_outline = %{scenario_outline | examples: update_examples}
    {%{feature | scenarios: [updated_scenario_outline | rest]}, :scenario_outline_example}
  end

  def process_line(line, {feature = %{description: current_description}, :feature_description}) do
    log line
    {%{feature | description: current_description <> line <> "\n"}, :feature_description}
  end

  def process_line(line, {feature = %{background_steps: current_background_steps}, :background_steps}) do
    log line
    new_step = StepsParser.string_to_step(line)
    {%{feature | background_steps: current_background_steps ++ [new_step]}, :background_steps}
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
    Logger.debug("Parsing line: \"#{line}\"")
  end

  defp tags_from_state(parser_state) do
    case parser_state do
      %{tags: tags} -> tags
      _             -> []
    end
  end

  defp table_line_to_columns(line) do
    line
    |> String.split("|", trim: true)
    |> Enum.map(&String.strip/1)
  end

end
