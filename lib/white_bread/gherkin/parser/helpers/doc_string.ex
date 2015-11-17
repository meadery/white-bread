defmodule WhiteBread.Gherkin.Parser.Helpers.DocString do

  def process_background_step_doc_string(line, feature, parser_state) do
    %{background_steps: steps} = feature

    updated_steps = steps |> add_doc_string_to_last_step(line)

    {
      %{feature | background_steps: updated_steps},
      parser_state
    }
  end

  def process_scenario_step_doc_string(line, feature, parser_state) do
    %{scenarios: [scenario | rest]} = feature
    %{steps: steps} = scenario

    updated_steps = steps |> add_doc_string_to_last_step(line)

    updated_scenario = %{scenario | steps: updated_steps}

    {
      %{feature | scenarios: [updated_scenario | rest]},
      parser_state
    }
  end

  defp add_doc_string_to_last_step(current_steps, line) do
    [%{doc_string: doc_string} = last_step | other_steps] = current_steps
      |> Enum.reverse
    updated_step = %{last_step | doc_string: doc_string <> line <> "\n"}
    updated_steps = [updated_step | other_steps] |> Enum.reverse

    updated_steps
  end
end
