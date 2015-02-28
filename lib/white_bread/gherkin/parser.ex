defmodule WhiteBread.Gherkin.Parser do
  require Logger
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  import String, only: [rstrip: 1, rstrip: 2, lstrip: 1]

  def parse_feature(feature_text) do
    feature_text
    |> String.split("\n", trim: true)
    |> Enum.map(&strip_whitespace/1)
    |> Enum.reduce({%Feature{}, :start}, &process_line/2)
    |> strip_state_atom
    |> reverse_step_order_for_each_scenario
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
    step = case line do
      "Given " <> text -> %Steps.Given{text: text}
      "When " <> text  -> %Steps.When{text: text}
      "Then " <> text  -> %Steps.Then{text: text}
      "And " <> text  -> %Steps.And{text: text}
      "But " <> text  -> %Steps.But{text: text}
    end
    %{steps: current_steps} = scenario
    updated_scenario = %{scenario | steps: [step | current_steps]}
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

  defp reverse_step_order_for_each_scenario(feature) do
    %{scenarios: scenarios} = feature
    updated_scenarios = Enum.map(scenarios, &reverse_step_order/1)
    %{feature | scenarios: updated_scenarios}
  end

  defp reverse_step_order(scenario = %{steps: steps}) do
    %{scenario | steps: Enum.reverse(steps)}
  end

  defp reverse_scenario_order(feature = %{scenarios: scenarios}) do
    %{feature | scenarios: Enum.reverse(scenarios)}
  end

end
