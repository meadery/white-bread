defmodule WhiteBread.CommandLine.ContextLoader do

  def load_context_files(context_path) do
    path_pattern = context_path <> "**"
    IO.puts "loading all contexts from #{path_pattern}"
    path_pattern
      |> Path.wildcard()
      |> Enum.filter(&script?/1)
      |> Enum.map(&Code.require_file/1)
  end

  def load_create_context([first | _] = context_options)
  when is_list(context_options)
  do
    existing_context = context_options
      |> Stream.filter(&File.exists?/1)
      |> Enum.take(1)
    case existing_context do
      [context] -> load_context_file(context)
      []        -> create_context(first)
    end
  end


  def load_context_file(path) do
    IO.puts "loading #{path}"
    [{context_module, _} | _] = Code.load_file(path)
    context_module
  end

  def context_from_string(context_name) do
    {context, []} = Code.eval_string(context_name)
    context
  end

  defp create_context(context) do
    context_text = WhiteBread.CodeGenerator.Context.empty_context
    IO.puts "Default context module not found in #{context}. "
    IO.puts "Create one [Y/n]? "
    acceptance = IO.read(:stdio, :line)

    unless acceptance == "n" <> "\n" do
      context |> Path.dirname |> File.mkdir_p!
      File.write!(context, context_text)
    end
    load_context_file(context)
  end

  defp script?(file_path) do
    file_path |> String.ends_with?(".exs")
  end

end
