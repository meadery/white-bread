defmodule WhiteBread.Gherkin.Parser.GenericLine do
  require Logger
  alias WhiteBread.Gherkin.Parser.Steps, as: StepsParser
  alias WhiteBread.Gherkin.Parser.Tables, as: TableParser
  alias WhiteBread.Gherkin.Elements.Scenario
  alias WhiteBread.Gherkin.Elements.ScenarioOutline
  alias WhiteBread.Gherkin.Parser.GenericLine.Helpers.DocString

  import String, only: [rstrip: 1, rstrip: 2, lstrip: 1]

  def process_line("", state) do
    Logger.debug("Parser skipping blank line")
    state
  end

  def process_line("#" <> _comment, state) do
    state
  end

  def process_line("@" <> line, {feature, _state}) do
    log line
    tags = line
      |> String.split("@", trim: true)
      |> Enum.map(&String.strip/1)
    {feature, %{tags: tags}}
  end

  def process_line("Feature: " <> name = line, {feature, state}) do
    feature_tags = tags_from_state(state)
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

  def process_line("Scenario: " <> name = line, {feature, state}) do
    log line
    previous_scenarios = feature.scenarios
    scenario_tags = tags_from_state(state)
    new_scenario = %Scenario{name: name, tags: scenario_tags}
    {
      %{feature | scenarios: [new_scenario | previous_scenarios]},
      :scenario_steps
    }
  end

  def process_line("Scenario Outline: " <> name = line, {feature, state}) do
    log line
    previous_scenarios = feature.scenarios
    scenario_tags = tags_from_state(state)
    new_scenario_outline = %ScenarioOutline{name: name, tags: scenario_tags}
    {
      %{feature | scenarios: [new_scenario_outline | previous_scenarios]},
      :scenario_steps
    }
  end

  # Stop recoding doc string
  def process_line(~s(""") <> _ = line, {feature, {:doc_string, prev_state}}) do
    log line
    { feature, prev_state }
  end

  # Start recoding doc string
  def process_line(~s(""") <> _ = line, {feature, prev_state}) do
    log line
    { feature, { :doc_string, prev_state } }
  end


  def process_line(line, {feature, {:doc_string, :background_steps} = state}) do
    log line
    DocString.add_doc_string_to_background_steps(line, feature, state)
  end

  def process_line(line, {feature, { :doc_string, _prev_state } = state}) do
    log line
    DocString.add_doc_string_to_step(line, feature, state)
  end

  # Tables as part of a step
  def process_line("|" <> line, {feature, :scenario_steps}) do
    log line
    %{scenarios: [scenario | rest]} = feature
    updated_scenario = scenario |> TableParser.add_table_row_to_last_step(line)
    {
      %{feature | scenarios: [updated_scenario | rest]},
      :scenario_steps
    }
  end

  # Tables as part of an example for a scenario
  def process_line("|" <> line, {feature, :scenario_outline_example}) do
    log line
    %{scenarios: [scenario_outline | rest]} = feature
    updated_scenario_outline = scenario_outline
      |> TableParser.add_table_row_to_example(line)
    {
      %{feature | scenarios: [updated_scenario_outline | rest]},
      :scenario_outline_example
    }
  end

  def process_line(line, {feature, :feature_description}) do
    log line
    %{description: current_description} = feature
    {
      %{feature | description: current_description <> line <> "\n"},
      :feature_description
    }
  end

  def process_line(line, {feature, :background_steps}) do
    log line
    %{background_steps: current_background_steps} = feature
    new_step = StepsParser.string_to_step(line)
    {
      %{feature | background_steps: current_background_steps ++ [new_step]},
      :background_steps
    }
  end

  def process_line(line, {feature, :scenario_steps}) do
    log line
    %{scenarios: [scenario | rest]} = feature
    updated_scenario = StepsParser.add_step_to_scenario(scenario, line)
    {
      %{feature | scenarios: [updated_scenario | rest]},
      :scenario_steps
    }
  end

  def process_line(line, state) do
    log line
    state
  end

  defp log(line) do
    Logger.debug(~s(Parsing line: "#{line}"))
  end

  defp tags_from_state(state) do
    case state do
      %{tags: tags} -> tags
      _             -> []
    end
  end

end
