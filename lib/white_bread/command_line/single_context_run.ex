defmodule WhiteBread.CommandLine.SingleContextRun do
  alias WhiteBread.CommandLine.ContextLoader

  @default_context "features/default_context.exs"

  def run_single_context(options, arguments) do
    context = options
      |> as_map
      |> get_context(arguments)

    result = context |> WhiteBread.run("features/", clean_options(options))

    %{failures: failures} = result
    failures
  end

  defp get_context(%{context: src}, _), do: ContextLoader.load_context_file(src)
  defp get_context(_, [context | _ ]), do: context_from_string(context)
  defp get_context(_, _), do: load_default_context

  defp load_default_context do
    unless File.exists?(@default_context), do: create_default_context
    ContextLoader.load_context_file(@default_context)
  end

  defp create_default_context do
    context_text = WhiteBread.CodeGenerator.Context.empty_context
    IO.puts "Default context module not found in #{@default_context}. "
    IO.puts "Create one [Y/n]? "
    acceptance = IO.read(:stdio, :line)

    unless acceptance == "n" <> "\n" do
      File.write(@default_context, context_text)
    end
  end

  defp context_from_string(context_name) do
    {context, []} = Code.eval_string(context_name)
    context
  end

  defp clean_options(raw_options) do
    raw_options
      |> Keyword.update(:tags, nil, &breakup_tag_string/1)
  end

  defp breakup_tag_string(tag_string) do
    tag_string
    |> String.split(",", trim: true)
    |> Enum.map(&String.strip/1)
  end

  defp as_map(keywordlist) do
    Enum.into(keywordlist, %{})
  end

end
