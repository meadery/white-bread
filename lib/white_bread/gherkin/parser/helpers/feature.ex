defmodule WhiteBread.Gherkin.Parser.Helpers.Feature do
  import String, only: [rstrip: 1]

  def process_feature_desc_line("As a " <> role = line, feature) do
    {
      feature
        |> add_role(role)
        |> add_line_to_description(line),
      :feature_description
    }
  end

  def process_feature_desc_line(line, feature) do
    {
      feature |> add_line_to_description(line),
      :feature_description
    }
  end

  def start_processing_feature(feature, name, tags) do
    {%{feature | name: rstrip(name), tags: tags}, :feature_description}
  end

  defp add_role(feature, role) do
    %{feature | role: String.strip(role)}
  end

  defp add_line_to_description(feature, line) do
    %{description: current_description} = feature
    %{feature | description: current_description <> line <> "\n"}
  end

end
