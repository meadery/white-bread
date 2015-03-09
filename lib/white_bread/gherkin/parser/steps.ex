defmodule WhiteBread.Gherkin.Parser.Steps do
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  def add_step_to_scenario(scenario, line) do
    step  = string_to_step(line)
    %{steps: current_steps} = scenario
    %{scenario | steps: current_steps ++ [step]}
  end

  def string_to_step(string) do
    case string do
      "Given " <> text -> %Steps.Given{text: text}
      "When " <> text  -> %Steps.When{text: text}
      "Then " <> text  -> %Steps.Then{text: text}
      "And " <> text  -> %Steps.And{text: text}
      "But " <> text  -> %Steps.But{text: text}
    end
  end

end
