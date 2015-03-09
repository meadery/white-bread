defmodule WhiteBread.Gherkin.Parser do
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Parser.GenericLine, as: LineParser
  alias WhiteBread.Gherkin.Parser.Steps, as: StepsParser

  import String, only: [strip: 1]

  def parse_feature(feature_text) do
    feature_text
    |> split_lines
    |> parse_each_line
    |> strip_state_atom
    |> correct_scenario_order
  end

  defp strip_state_atom({feature, _state}) do
    feature
  end

  defp correct_scenario_order(feature = %{scenarios: scenarios}) do
    %{feature | scenarios: Enum.reverse(scenarios)}
  end

  defp split_lines(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(&strip/1)
  end

  defp parse_each_line(lines) do
    lines |> Enum.reduce({%Feature{}, :start}, &LineParser.process_line/2)
  end

end
