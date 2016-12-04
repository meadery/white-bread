defmodule WhiteBread.CommandLine.SuiteRun do
  alias WhiteBread.CommandLine.ContextLoader
  alias WhiteBread.Suite

  def run_suites(
    config_path: config_path,
    contexts: context_path)
  do
    ContextLoader.load_context_files(context_path)

    config_path
      |> get_suites_from_config
      |> Enum.map(fn suite -> run_suite(suite, context_path: context_path) end)
      |> Enum.flat_map(fn results -> results.failures end)
  end

  defp run_suite(%Suite{} = suite, context_path: context_path) do
    IO.puts "\n\nSuite: #{suite.name}"
    ContextLoader.ensure_context(suite.context, context_path)
    WhiteBread.run(
      suite.context,
      suite.feature_paths,
      tags: suite.tags,
      roles: suite.roles,
      async: suite.run_async
    )
  end

  defp get_suites_from_config(path) do
    IO.puts "loading config from #{path}"
    if (suite_config_missing?(path)), do: create_config(path)
    [{suite_config_module, _} | _] = Code.load_file(path)
    suite_config_module.suites
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

end
