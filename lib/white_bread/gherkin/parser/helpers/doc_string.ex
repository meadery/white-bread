defmodule WhiteBread.Gherkin.Parser.GenericLine.Helpers.DocString do

  def add_doc_string_to_background_steps(line, feature, parser_state) do
    %{background_steps: current_steps} = feature
    [%{doc_string: doc_string} = last_step | other_steps] = current_steps
      |> Enum.reverse

    updated_step = %{last_step | doc_string: doc_string <> line <> "\n"}
    updated_steps = [updated_step | other_steps] |> Enum.reverse

    {
      %{feature | background_steps: updated_steps},
      parser_state
    }
  end

  def add_doc_string_to_step(line, feature, parser_state) do
    %{scenarios: [scenario | rest]} = feature
    %{steps: current_steps} = scenario
    [%{doc_string: doc_string} = last_step | other_steps] = current_steps
      |> Enum.reverse

    updated_step = %{last_step | doc_string: doc_string <> line <> "\n"}
    updated_steps = [updated_step | other_steps] |> Enum.reverse
    updated_scenario = %{scenario | steps: updated_steps}

    {
      %{feature | scenarios: [updated_scenario | rest]},
      parser_state
    }
  end
end
