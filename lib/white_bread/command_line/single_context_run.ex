defmodule WhiteBread.CommandLine.SingleContextRun do
  alias WhiteBread.CommandLine.ContextLoader

  def run_single_context(options, arguments, default_context: default) do
    context = options
      |> as_map
      |> get_context(arguments, default_context: default)

    result = context |> WhiteBread.run("features/", clean_options(options))

    %{failures: failures} = result
    failures
  end

  defp get_context(%{context: src}, _args, _defaults) do
    ContextLoader.load_context_file(src)
  end
  defp get_context(_opts, [context | _ ], _defaults) do
    context_from_string(context)
  end
  defp get_context(_opts, _args, default_context: context) do
    load_create_context(context)
  end

  defp load_create_context(context) do
    unless File.exists?(context), do: create_context(context)
    ContextLoader.load_context_file(context)
  end

  defp create_context(context) do
    context_text = WhiteBread.CodeGenerator.Context.empty_context
    IO.puts "Default context module not found in #{context}. "
    IO.puts "Create one [Y/n]? "
    acceptance = IO.read(:stdio, :line)

    unless acceptance == "n" <> "\n" do
      File.write(context, context_text)
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
