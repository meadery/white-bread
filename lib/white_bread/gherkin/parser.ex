defmodule WhiteBread.Gherkin.Parser do
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature

  def parse_feature(feature_text) do
    {feature, _}  = feature_text
    |> String.split("\n")
    |> Enum.reduce({%Feature{}, :start}, &process_line/2)

    feature
  end

  defp process_line("Feature: " <> name, {feature, :start}) do
    {%{feature | name: String.rstrip(name)}, :start}
  end

  defp process_line(_line, state) do
    state
  end

end
