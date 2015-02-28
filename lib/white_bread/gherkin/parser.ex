defmodule WhiteBread.Gherkin.Parser do
  require Logger
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario
  alias WhiteBread.Gherkin.Parser.Steps, as: StepsParser

  import String, only: [rstrip: 1, rstrip: 2, lstrip: 1]

  def parse_feature(feature_text) do
    feature_text
    |> String.split("\n", trim: true)
    |> Enum.map(&strip_whitespace/1)
    |> Enum.reduce({%Feature{}, :start}, &process_line/2)
    |> strip_state_atom
    |> StepsParser.reverse_step_order_for_each_scenario
    |> reverse_scenario_order
  end

  defp process_line("Feature: " <> name = line, {feature, :start}) do
    log line
    {%{feature | name: rstrip(name)}, :feature_description}
  end

  defp process_line("Scenario: " <> name = line, {feature = %{scenarios: previous_scenarios}, _}) do
    log line
    new_scenario = %Scenario{name: name}
    {%{feature | scenarios: [new_scenario | previous_scenarios]}, :scenario_steps}
  end

  defp process_line(line, {feature = %{description: current_description}, :feature_description}) do
    log line
    {%{feature | description: current_description <> line <> "\n"}, :feature_description}
  end

  defp process_line(line, {feature = %{scenarios: [scenario | rest]}, :scenario_steps}) do
    log line
    updated_scenario = StepsParser.add_step_to_scenario(scenario, line)
    {%{feature | scenarios: [updated_scenario | rest]}, :scenario_steps}
  end

  defp process_line(line, state) do
    log line
    state
  end

  defp log(line) do
    Logger.debug("Parsing line: #{line}")
  end

  defp strip_whitespace(line) do
    line |> lstrip |> rstrip
  end

  defp strip_state_atom({feature, _state}) do
    feature
  end

  defp reverse_scenario_order(feature = %{scenarios: scenarios}) do
    %{feature | scenarios: Enum.reverse(scenarios)}
  end

end
