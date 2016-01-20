defmodule WhiteBread.CommandLine.SingleContextRun do
  alias WhiteBread.CommandLine.ContextLoader

  def run_single_context(options, arguments, default_contexts: defaults)
  when is_list(defaults)
  do
    context = options
      |> as_map
      |> get_context(arguments, default_contexts: defaults)

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
  defp get_context(_opts, _args, default_contexts: contexts) do
    load_create_context(contexts)
  end

  defp load_create_context([first | _] = context_options)
  when is_list(context_options)
  do
    existing_context = context_options
      |> Stream.filter(&File.exists?/1)
      |> Enum.take(1)
    case existing_context do
      [context] -> ContextLoader.load_context_file(context)
      []        -> create_context(first)
    end
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
