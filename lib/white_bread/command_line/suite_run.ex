defmodule WhiteBread.CommandLine.SuiteRun do
  alias WhiteBread.CommandLine.ContextLoader
  alias WhiteBread.CommandLine.ContextPerFeature
  alias WhiteBread.Suite

  def run_suites(
    _options,
    _arguments,
    config_path: config_path,
    contexts: context_path)
  do
    handle_suites = fn
      {:ok, context_feature_suites}, suites -> [context_feature_suites | suites]
      {:error, _}, suites -> suites
    end

    ContextLoader.load_context_files(context_path)

    {context_features, suites} = get_suites_from_config(config_path)
    
    handle_suites.(ContextPerFeature.build_suites(context_features), suites) |>
    suite_results
  end

  defp suite_results(suites) do
    suites
      |> Enum.map(&run_suite/1)
      |> Enum.flat_map(fn results -> results.failures end)
  end

  defp run_suite(%Suite{} = suite) do
    IO.puts "\n\nSuite: #{suite.name}"
    suite.context
      |> WhiteBread.run(suite.feature_paths, tags: suite.tags)
  end

  defp get_suites_from_config(path) do
    IO.puts "loading config from #{path}"
    [{suite_config_module, _} | _] = Code.load_file(path)
    {suite_config_module.context_per_feature, suite_config_module.suites}
  end

end
