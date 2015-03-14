defmodule WhiteBread.CodeGenerator.Step do

  @regex_step_template """
  {{step}}_ ~r/^{{text}}$/, fn state ->
    {:ok, state}
  end
  """

  def regex_code_for_step(%{text: text, __struct__: struct_type}) do
    step_type = struct_type
    |> Atom.to_string
    |> String.replace("Elixir.WhiteBread.Gherkin.Elements.Steps.", "")
    |> String.downcase

    @regex_step_template
    |> String.replace("{{step}}", step_type)
    |> String.replace("{{text}}", text)
  end

end
