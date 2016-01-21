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
    ContextLoader.context_from_string(context)
  end
  defp get_context(_opts, _args, default_contexts: contexts) do
    ContextLoader.load_create_context(contexts)
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
