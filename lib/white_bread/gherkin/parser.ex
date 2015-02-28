defmodule WhiteBread.Gherkin.Parser do
  require Logger
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature

  def parse_feature(feature_text) do
    {feature, _}  = feature_text
    |> String.lstrip
    |> String.split("\n")
    |> Enum.reduce({%Feature{}, :start}, &process_line/2)

    feature
  end

  defp process_line("Feature: " <> name = line, {feature, :start}) do
    log line
    {%{feature | name: String.rstrip(name)}, :start}
  end

  defp process_line(line, state) do
    log line
    state
  end

  defp log(line) do
    Logger.debug("Parsing line: #{line}")
  end

end
