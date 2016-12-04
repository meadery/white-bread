defmodule WhiteBread.CommandLine.ContextLoader do

  def load_context_files(context_path) do
    path_pattern = context_path <> "**"
    IO.puts "loading all contexts from #{path_pattern}"
    path_pattern
      |> Path.wildcard()
      |> Enum.filter(&script?/1)
      |> Enum.map(&Code.require_file/1)
  end

  def ensure_context(context, context_path) do
    if !Code.ensure_loaded?(context), do: create_context(context, context_path)
    Code.ensure_loaded(context)
  end

  def create_context(context, context_path) do
    path = context_path <> Macro.underscore(context) <> ".exs"

    IO.puts "Context module not found #{context} (#{path})"
    IO.puts "Create one [Y/n]? "
    acceptance = IO.read(:stdio, :line)

    unless acceptance == "n" <> "\n" do
      context_text = WhiteBread.CodeGenerator.Context.empty_context(context)
      path |> Path.dirname |> File.mkdir_p!
      File.write!(path, context_text)
    end
    load_context_file(path)
  end

  defp load_context_file(path) do
    IO.puts "loading #{path}"
    [{context_module, _} | _] = Code.load_file(path)
    context_module
  end

  defp script?(file_path) do
    file_path |> String.ends_with?(".exs")
  end

end
