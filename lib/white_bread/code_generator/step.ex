defmodule WhiteBread.CodeGenerator.Step do

  @regex_step_template """
  {{step}}_ ~r/^{{text}}$/, fn state ->
    {:ok, state}
  end
  """

  @named_group_regex_step_template """
  {{step}}_ ~r/^{{text}}$/,
  fn state, %{{{groups}}} ->
    {:ok, state}
  end
  """

  @quoted_string_regex ~r/"[^"]+"/

  def regex_code_for_step(%{text: text, __struct__: struct_type}) do
    step_type = struct_type
    |> Atom.to_string
    |> String.replace("Elixir.WhiteBread.Gherkin.Elements.Steps.", "")
    |> String.downcase

    case @quoted_string_regex |> Regex.match?(text) do
      true  -> regex_code_for_step(:complex, text, step_type)
      false -> regex_code_for_step(:simple, text, step_type)
    end

  end

  def regex_code_for_step(:simple, text, step_type) do
    @regex_step_template
    |> String.replace("{{step}}", step_type)
    |> String.replace("{{text}}", text)
  end

  def regex_code_for_step(:complex, text, step_type) do
    %{template: regex, groups: groups} = named_groups_for_string(text)

    group_text = groups
    |> Enum.map(fn(name) -> "#{name}: _#{name}" end)
    |> Enum.join(",")

    @named_group_regex_step_template
    |> String.replace("{{step}}", step_type)
    |> String.replace("{{text}}", regex)
    |> String.replace("{{groups}}", group_text)
  end

  def named_groups_for_string(string) when is_binary(string) do
    named_groups_for_string %{template: "", groups: [], unproccessed_string: string}
  end

  def named_groups_for_string(%{unproccessed_string: "", template: template, groups: groups}) do
    %{template: template, groups: groups}
  end

  def named_groups_for_string(%{template: old_template, groups: current_groups, unproccessed_string: string}) do
    argument = (Enum.count(current_groups) + 1)
    |> string_for_number

    [before, remaining] = Regex.split(@quoted_string_regex, string, [parts: 2])
    template = old_template <> before <> "\"(?<" <> argument <> ">[^\"]+)\""

    named_groups_for_string %{template: template, groups: current_groups ++ [argument], unproccessed_string: remaining}
  end

  defp string_for_number(number) do
    "argument_" <> case number do
      1 -> "one"
      2 -> "two"
      3 -> "three"
      4 -> "four"
      5 -> "five"
      6 -> "six"
      _ -> "another"
    end
  end

end
