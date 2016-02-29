defmodule WhiteBread.Feature.Finder do
  import String, only: [ends_with?: 2]

  def find_in_path(dir_paths) when is_list(dir_paths) do
    dir_paths
      |> Enum.flat_map(&find_in_path/1)
  end

  def find_in_path(dir_path) do
    path_pattern = dir_path <> "**"
    path_pattern
      |> Path.wildcard()
      |> get_only_feature_files
      |> sort_alphabetically
  end

  defp get_only_feature_files(file_paths) do
    file_paths
      |> Enum.filter(&feature_file?/1)
  end

  defp sort_alphabetically(file_paths) do
    file_paths |> Enum.sort
  end

  defp feature_file?(path) do
    path |> ends_with?(".feature")
  end
end
