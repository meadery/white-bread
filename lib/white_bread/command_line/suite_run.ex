defmodule WhiteBread.CommandLine.SuiteRun do
  alias WhiteBread.CommandLine.ContextLoader
  alias WhiteBread.Suite

  def run_suites(
    options,
    config_path: config_path,
    contexts: context_path)
  do
    add_outputers()

    ContextLoader.load_context_files(context_path)

    config_path
      |> get_suites_from_config(options)
      |> Stream.map(fn suite -> run_suite(suite, context_path: context_path) end)
      |> Enum.flat_map(fn results -> results.failures end)
  end

  defp run_suite(%Suite{} = suite, context_path: context_path) do
    WhiteBread.Outputer.report({:suite, suite.name})
    ContextLoader.ensure_context(suite.context, context_path)
    WhiteBread.run(
      suite.context,
      suite.feature_paths,
      tags: suite.tags,
      roles: suite.roles,
      async: suite.run_async
    )
  end

  defp get_suites_from_config(path, options) do
    IO.puts "loading config from #{path}"

    if (suite_config_missing?(path)), do: create_config(path)
    [{suite_config_module, _} | _] = Code.load_file(path)

    suite_config_module.suites
    |> filter_to_suite(Keyword.get(options, :suite))
  end

  defp suite_config_missing?(path), do: !File.exists?(path)

  defp create_config(path) do
    IO.puts "Config file not found at #{path}. "
    IO.puts "Create one [Y/n]? "

    acceptance = IO.read(:stdio, :line)
    |> String.downcase
    |> String.trim

    unless acceptance == "n" do
      file_text = WhiteBread.CodeGenerator.SuiteConfig.empty_config
      path |> Path.dirname |> File.mkdir_p!
      File.write!(path, file_text)
    end
  end

  defp filter_to_suite(suites, _requested_suite = nil), do: suites
  defp filter_to_suite(suites, requested_suite) do
    suites
    |> Stream.filter(fn suite -> suite.name == requested_suite end)
  end

  defp add_outputers do
    true = Enum.all?(outputers(), &Code.ensure_loaded?/1)
    for o <- outputers() do
      WhiteBread.EventManager.add_handler(o, [])
    end
  end
  defp outputers do
    Keyword.keys(Application.fetch_env!(:white_bread, :outputers))
  end
end
