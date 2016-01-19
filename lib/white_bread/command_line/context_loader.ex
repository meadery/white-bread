defmodule WhiteBread.CommandLine.ContextLoader do

  @context_path "features/contexts/"

  def load_context_files() do
    path_pattern = @context_path <> "**"
    path_pattern
      |> Path.wildcard()
      |> Enum.filter(&is_script?/1)
      |> Enum.map(&Code.require_file/1)
  end

  def load_context_file(path) do
    IO.puts "loading #{path}"
    [{context_module, _} | _] = Code.load_file(path)
    context_module
  end

  defp is_script?(file_path) do
    fn(file_path) -> file_path |> String.ends_with?(".exs") end
  end
  
end
