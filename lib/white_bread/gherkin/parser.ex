defmodule WhiteBread.Gherkin.Parser do
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Parser.GenericLine, as: LineParser

  def parse_feature(feature_text) do
    feature_text
    |> process_lines
    |> parse_each_line
    |> correct_scenario_order
  end

  defp correct_scenario_order(feature = %{scenarios: scenarios}) do
    %{feature | scenarios: Enum.reverse(scenarios)}
  end

  defp process_lines(string) do
    {:ok, output} =
      string |> String.split("\n", trim: true)
             |> Enum.reduce({:ok, []}, &__MODULE__.process_line/2)

    Enum.reverse(output)
  end

  def process_line(line, {state, lines}) do
    process_line(String.lstrip(line), {state, lines, line})
  end

  # Multiline / Doc string processing
  def process_line(line = ~s(""") <> _, {:ok, lines, original_line}) do
    indent_length = String.length(original_line) -
                    String.length(String.lstrip(original_line))
    {{:multiline, indent_length}, [ line | lines ]}
  end
  def process_line(line = ~s(""") <> _, {{:multiline, _}, lines, _}) do
    {:ok, [ line | lines ]}
  end
  def process_line(_, {{:multiline, indent} = state, lines, original_line}) do
    {strippable, doc_string} = String.split_at(original_line, indent)
    {state, [ String.lstrip(strippable) <> doc_string | lines ]}
  end

  # Default processing
  def process_line(line, {:ok, lines, _}), do: {:ok, [ line | lines ]}

  defp parse_each_line(lines) do
    {feature, _end_state} = lines
    |> Enum.reduce({%Feature{}, :start}, &LineParser.process_line/2)
    feature
  end

end
