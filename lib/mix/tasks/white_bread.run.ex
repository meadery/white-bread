defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  alias WhiteBread.CommandLine.SuiteRun
  alias WhiteBread.CommandLine.SingleContextRun

  @shortdoc "Runs all the feature files with WhiteBread"

  @default_context "features/default_context.exs"
  @default_suite_config "features/config.exs"
  @context_path "features/contexts/"

  def run(argv) do
    {options, arguments, _} = OptionParser.parse(argv)
    start_app(argv)
    failures = run_based_on_setup(options, arguments)
    System.at_exit fn _ ->
      if Enum.count(failures) > 0, do: exit({:shutdown, 1})
    end
  end

  defp run_based_on_setup(options, arguments) do
    if run_as_suite?(options, arguments) do
      SuiteRun.run_suites(options, arguments,
        config_path: @default_suite_config, contexts: @context_path
      )
    else
      SingleContextRun.run_single_context(
        options, arguments, default_context: @default_context
      )
    end
  end

  defp run_as_suite?(options, arguments) do
    suite_config_present?
    && !single_context_config?(options, arguments)
  end

  defp suite_config_present?, do: File.exists?(@default_suite_config)

  defp single_context_config?(options, _arguments) do
    Dict.has_key?(options, :tags)
    || Dict.has_key?(options, :context)
  end

  defp start_app(argv) do
    unless "--no-start" in argv do
      Mix.Task.run "app.start", argv
    end
  end

end
