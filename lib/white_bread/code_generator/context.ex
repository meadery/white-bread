defmodule WhiteBread.CodeGenerator.Context do

  @empty_context """
  defmodule {{NAME}} do
    use WhiteBread.Context
  end
  """

  def empty_context(context) do
    String.replace(@empty_context, "{{NAME}}", context_as_string(context))
  end

  def context_as_string(context) do
    context
    |> Atom.to_string
    |> String.replace("Elixir.", "")
  end

end
