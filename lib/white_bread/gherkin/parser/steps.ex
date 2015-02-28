defmodule WhiteBread.Gherkin.Parser.Steps do
  require Logger
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  def add_step_to_scenario(scenario, line) do
    step = case line do
      "Given " <> text -> %Steps.Given{text: text}
      "When " <> text  -> %Steps.When{text: text}
      "Then " <> text  -> %Steps.Then{text: text}
      "And " <> text  -> %Steps.And{text: text}
      "But " <> text  -> %Steps.But{text: text}
    end
    %{steps: current_steps} = scenario
    updated_scenario = %{scenario | steps: [step | current_steps]}
  end

  def reverse_step_order_for_each_scenario(feature) do
    %{scenarios: scenarios} = feature
    updated_scenarios = Enum.map(scenarios, &reverse_step_order/1)
    %{feature | scenarios: updated_scenarios}
  end

  defp reverse_step_order(scenario = %{steps: steps}) do
    %{scenario | steps: Enum.reverse(steps)}
  end

end
