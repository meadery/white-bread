defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  alias WhiteBread.Suite

  @shortdoc "Runs all the feature files with WhiteBread"
  @default_context "features/default_context.exs"
  @default_suite_config "features/config.exs"
  @context_path "features/contexts/"

  def run(argv) do
    {options, arguments, _} = OptionParser.parse(argv)
    start_app(argv)
    if run_as_suite?(options, arguments) do
      run_suites(options, arguments)
    else
      run_single_context(options, arguments)
    end
  end

  def run_as_suite?(options, arguments) do
    suite_config_present?
    && !single_context_config?(options, arguments)
  end

  def suite_config_present?, do: File.exists?(@default_suite_config)

  def single_context_config?(options, arguments) do
    Dict.has_key?(options, :tags)
    || Dict.has_key?(options, :context)
  end

  def run_suites(_options, _arguments) do
    load_context_files

    failures = @default_suite_config
      |> get_suites_from_config
      |> Enum.map(&run_suite/1)
      |> Enum.flat_map(fn results -> results.failures end)

    System.at_exit fn _ ->
      if Enum.count(failures) > 0, do: exit({:shutdown, 1})
    end
  end

  def run_suite(%Suite{} = suite) do
    IO.puts "\n\nSuite: #{suite.name}"
    suite.context
      |> WhiteBread.run(suite.feature_paths, tags: suite.tags)
  end

  def load_context_files() do
    path_pattern = @context_path <> "**"
    path_pattern
      |> Path.wildcard()
      |> Enum.filter(&is_script?/1)
      |> Enum.map(&Code.require_file/1)
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

  def get_suites_from_config(path) do
    IO.puts "loading config from #{path}"
    [{suite_config_module, _} | _] = Code.load_file(path)
    suite_config_module.suites
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

  defp is_script?(file_path) do
    fn(file_path) -> file_path |> String.ends_with?(".exs") end
  end

end
