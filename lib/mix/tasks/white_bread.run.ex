defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  @shortdoc "Runs all the feature files with WhiteBread"
  @default_context "features/default_context.exs"
  @default_suite_config "features/config.exs"

  def run(argv) do
    {options, arguments, _} = OptionParser.parse(argv)
    start_app(argv)
    run_single_context(options, arguments)
  end

  def run_single_context(options, arguments) do
    context = options
      |> as_map
      |> get_context(arguments)

    result = context |> WhiteBread.run("features/", clean_options(options))

    %{failures: failures} = result
    System.at_exit fn _ ->
      if Enum.count(failures) > 0, do: exit({:shutdown, 1})
    end
  end

  def start_app(argv) do
    unless "--no-start" in argv do
      Mix.Task.run "app.start", argv
    end
  end

  def get_context(%{context: path}, _), do: load_context_file(path)
  def get_context(_, [context | _ ]), do: context_from_string(context)
  def get_context(_, _), do: load_default_context

  def load_default_context do
    unless File.exists?(@default_context), do: create_default_context
    load_context_file(@default_context)
  end

  def load_context_file(path) do
    IO.puts "loading #{path}"
    [{context_module, _} | _] = Code.load_file(path)
    context_module
  end

  def create_default_context do
    context_text = WhiteBread.CodeGenerator.Context.empty_context
    IO.puts "Default context module not found in #{@default_context}. "
    IO.puts "Create one [Y/n]? "
    acceptance = IO.read(:stdio, :line)

    unless acceptance == "n" <> "\n" do
      File.write(@default_context, context_text)
    end
  end

  def context_from_string(context_name) do
    {context, []} = Code.eval_string(context_name)
    context
  end

  def clean_options(raw_options) do
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
