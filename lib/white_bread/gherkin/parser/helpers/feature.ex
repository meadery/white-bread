defmodule WhiteBread.Gherkin.Parser.Helpers.Feature do
  import String, only: [rstrip: 1]

  def process_feature_desc_line(line, feature) do
    %{description: current_description} = feature
    {
      %{feature | description: current_description <> line <> "\n"},
      :feature_description
    }
  end

  def start_processing_feature(feature, name, tags) do
    {%{feature | name: rstrip(name), tags: tags}, :feature_description}
  end

end
