defmodule WhiteBread.Feature.Finder do
  import String, only: [ends_with?: 2]

  def find_in_path(dir_path) do
    Path.wildcard(dir_path <> "**")
    |> get_only_feature_files
    |> sort_alphabetically
  end

  defp get_only_feature_files(file_paths) do
    file_paths
      |> Enum.filter(fn(file_path) -> file_path |> ends_with? ".feature" end)
  end

  defp sort_alphabetically(file_paths) do
    file_paths |> Enum.sort
  end
end
