defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  alias WhiteBread.CommandLine.SuiteRun

  @shortdoc "Runs all the feature files with WhiteBread"

  @suite_config_option :config
  @default_suite_config "features/config.exs"

  @context_path_option :contexts
  @context_path "features/contexts/"

  def run(argv) do
    {options, arguments, _} = argv
    |> OptionParser.parse(switches: [suite: :string])
    |> check_for_deprecations

    start_app(argv)
    failures = run_suite(options, arguments)
    System.at_exit fn _ ->
      if Enum.count(failures) > 0, do: exit({:shutdown, 1})
    end

    WhiteBread.Application.stop()
  end

  defp run_suite(options, _arguments) do
    SuiteRun.run_suites(
      options,
      config_path: config_path(options),
      contexts: contexts_path(options)
    )
  end

  defp start_app(argv) do
    unless "--no-start" in argv do
      Mix.Task.run "app.start", argv
    end
  end

  defp config_path(options) do
    if Keyword.has_key?(options, @suite_config_option) do
      Keyword.get(options, @suite_config_option)
    else
      @default_suite_config
    end
  end

  defp contexts_path(options) do
    if Keyword.has_key?(options, @context_path_option) do
      Keyword.get(options, @context_path_option)
    else
      @context_path
    end
  end

  defp check_for_deprecations({options, _arguments, _} = input) do
    if Keyword.has_key?(options, :context) do
      error_exit "Specifying a context on the command line is no longer supported. Use suite configuration instead."
    end
    if Keyword.has_key?(options, :tags) do
      error_exit "Specifying tags on the command line is not yet supported in this version. Create a suite with the required filter."
    end
    input
  end

  defp error_exit(message) do
    IO.puts message
    exit({:shutdown, 1})
  end

end
