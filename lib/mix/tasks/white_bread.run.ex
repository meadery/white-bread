defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  alias WhiteBread.CommandLine.SuiteRun
  alias WhiteBread.CommandLine.SingleContextRun

  @shortdoc "Runs all the feature files with WhiteBread"

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
      SuiteRun.run_suites(options, arguments)
    else
      SingleContextRun.run_single_context(options, arguments)
    end
  end

  defp run_as_suite?(options, arguments) do
    SuiteRun.suite_config_present?
    && !single_context_config?(options, arguments)
  end

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
