defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  @shortdoc "Runs all the feature files with WhiteBread"

  def run(argv) do
    {options, arguments, _} = OptionParser.parse(argv)
    case arguments do
      [context_name | _ ] -> context_from_string(context_name) |> run("features/", options)
      []                  -> load_default_context |> run("features/", options)
    end

  end

  def load_default_context do
    [{context_module, _} | _] = Code.load_file("features/default_context.exs")
    context_module
  end

  def context_from_string(context_name) do
    {context, []} = Code.eval_string(context_name)
    context
  end

  def run(context, path, raw_options \\ []) do

    options = raw_options
    |> Keyword.update(:tags, nil, &breakup_tag_string/1)

    result = context |> WhiteBread.run(path, options)

    result
    |> WhiteBread.FinalResultPrinter.text
    |> IO.puts

    %{failures: failures} = result
    System.at_exit fn _ ->
      if Enum.count(failures) > 0, do: exit({:shutdown, 1})
    end
  end

  defp breakup_tag_string(tag_string) do
    tag_string
    |> String.split(",", trim: true)
    |> Enum.map(&String.strip/1)
  end

end
