defmodule WhiteBread.CommandLine.SuiteRun do
  alias WhiteBread.CommandLine.ContextLoader
  alias WhiteBread.Suite
  alias WhiteBread.ContextFeature

  def run_suites(
    _options,
    _arguments,
    config_path: config_path,
    contexts: context_path)
  do
    handle_runner = fn
      {:per_feature, contexts} -> context_per_feature_results(contexts)
      {:suites, suites} -> suite_results(suites)
    end

    ContextLoader.load_context_files(context_path)

    IO.puts "****** Has module *****"
    IO.inspect Code.ensure_loaded?(Module.concat(["WhiteBread", "Example", DefaultContext]))
    # get all feature file names
    # make list of modules out of it using Module.concat
    # Make a feature struct and pass to new run_suite for features

    handle_runner.(get_suites_from_config(config_path))
  end

  defp context_per_feature_results(context_features) do
    context_features
      |> Enum.map(&run_context_per_feature/1)
      |> Enum.flat_map(fn results -> results.failures end)
  end

  defp run_context_per_feature(%ContextFeature{} = context_feature) do
    IO.puts "\n\n**** Context per feature"
    WhiteBread.run(context_feature.context, context_feature.feature_path, tags: [])
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
    case suite_config_module.context_per_feature do
      {:on, true} ->
        {:per_feature, suite_config_module.context_per_feature}
      _ ->
        {:suites, suite_config_module.suites }
    end
  end

end
