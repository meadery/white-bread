defmodule WhiteBread.Gherkin.Parser.GenericLine do
  require Logger
  alias WhiteBread.Gherkin.Parser.Helpers.Feature, as: FeatureParser
  alias WhiteBread.Gherkin.Parser.Helpers.Scenario, as: ScenarioParser
  alias WhiteBread.Gherkin.Parser.Helpers.Steps, as: StepsParser
  alias WhiteBread.Gherkin.Parser.Helpers.Tables, as: TableParser
  alias WhiteBread.Gherkin.Parser.Helpers.DocString, as: DocStringParser

  def process_line(line, state) do
    line
      |> log
      |> process(state)
  end

  defp process("", state) do
    state
  end

  defp process("#" <> _comment, state) do
    state
  end

  defp process("@" <> line, {feature, _state}) do
    tags = line
      |> String.split("@", trim: true)
      |> Enum.map(&String.strip/1)
    {feature, %{tags: tags}}
  end

  defp process("Feature: " <> name, {feature, state}) do
    feature_tags = tags_from_state(state)
    FeatureParser.start_processing_feature(feature, name, feature_tags)
  end

  defp process("Background:" <> _, {feature, _} ) do
    {feature, :background_steps}
  end

  defp process("Examples:" <> _, {feature, _} ) do
    {feature, :scenario_outline_example}
  end

  defp process("Scenario: " <> name, {feature, state}) do
    tags = tags_from_state(state)
    ScenarioParser.start_processing_scenario(feature, name, tags)
  end

  defp process("Scenario Outline: " <> name, {feature, state}) do
    tags = tags_from_state(state)
    ScenarioParser.start_processing_scenario_outline(feature, name, tags)
  end

  # Stop recoding doc string
  defp process(~s(""") <> _, {feature, {:doc_string, prev_state}}) do
    DocStringParser.stop_processing_doc_string(feature, prev_state)
  end

  # Start recoding doc string
  defp process(~s(""") <> _, {feature, state}) do
    DocStringParser.start_processing_doc_string(feature, state)
  end

  defp process(line, {feature, {:doc_string, :background_steps} = state}) do
    DocStringParser.process_background_step_doc_string(line, feature, state)
  end

  defp process(line, {feature, { :doc_string, _prev_state } = state}) do
    DocStringParser.process_scenario_step_doc_string(line, feature, state)
  end

  # Tables as part of a step
  defp process("|" <> line, {feature, :scenario_steps}) do
    TableParser.process_step_table_line(line, feature)
  end

  # Tables as part of an example for a scenario
  defp process("|" <> line, {feature, :scenario_outline_example}) do
    TableParser.process_outline_table_line(line, feature)
  end

  defp process(line, {feature, :feature_description}) do
    FeatureParser.process_feature_desc_line(line, feature)
  end

  defp process(line, {feature, :background_steps}) do
    StepsParser.process_background_step_line(line, feature)
  end

  defp process(line, {feature, :scenario_steps}) do
    StepsParser.process_scenario_step_line(line, feature)
  end

  defp process(_line, state) do
    state
  end

  defp log(line) do
    Logger.debug(~s(Parsing line: "#{line}"))
    line
  end

  defp tags_from_state(state) do
    case state do
      %{tags: tags} -> tags
      _             -> []
    end
  end

end
