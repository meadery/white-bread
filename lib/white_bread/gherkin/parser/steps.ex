defmodule WhiteBread.Gherkin.Parser.Steps do
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  def add_step_to_scenario(scenario, line) do
    step  = string_to_step(line)
    %{steps: current_steps} = scenario
    %{scenario | steps: current_steps ++ [step]}
  end

  def add_table_row_to_last_step(scenario, new_row) do
    %{steps: current_steps} = scenario
    [%{table_data: current_rows} = last_step | other_steps] = current_steps |> Enum.reverse

    updated_step = %{last_step | table_data: current_rows ++ [new_row]}
    updated_steps = [updated_step | other_steps] |> Enum.reverse

    %{scenario | steps: updated_steps}
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
