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
      |> String.replace("Elixir.Gherkin.Elements.Steps.", "")
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
    string_data = %{template: "", groups: [], unproccessed_string: string}
    named_groups_for_string(string_data)
  end

  def named_groups_for_string(%{unproccessed_string: ""} = string_data) do
    %{template: string_data.template, groups: string_data.groups}
  end

  def named_groups_for_string(string_data) do
    %{template: template, groups: groups, unproccessed_string: string}
      = string_data

    next_number = Enum.count(groups) + 1
    argument = string_for_number(next_number)

    case Regex.split(@quoted_string_regex, string, [parts: 2]) do
        [before, remaining] ->
          %{}
            |> Map.put(:template, update_template(template, before, argument))
            |> Map.put(:groups, groups ++ [argument])
            |> Map.put(:unproccessed_string, remaining)
            |> named_groups_for_string
        [string_end] ->
          %{template: template <> string_end, groups: groups}
    end
  end

  defp update_template(old_template, before, argument) do
    old_template <> before <> ~s/\"(?</ <> argument <> ~s/>[^\"]+)\"/
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
