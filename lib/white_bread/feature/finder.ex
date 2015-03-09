defmodule WhiteBread.Feature.Finder do
  import String, only: [ends_with?: 2]
  import File, only: [dir?: 1]

  def find_in_path(dir_path) do
    paths = File.ls!(dir_path)

    root_files = paths
    |> get_only_feature_files
    |> prepend_dir_path(dir_path)

    sub_dir_files = paths
    |> prepend_dir_path(dir_path)
    |> get_only_directories
    |> Enum.flat_map(fn(sub_dir) -> find_in_path(sub_dir <> "/") end)

    root_files
    |> Enum.into(sub_dir_files)
    |> sort_alphabetically
  end

  defp get_only_feature_files(file_paths) do
    file_paths |> Enum.filter(fn(file_path) -> file_path |> ends_with? ".feature" end)
  end

  defp get_only_directories(file_paths) do
    file_paths |> Enum.filter(fn(file_path) -> file_path |> dir? end)
  end

  defp sort_alphabetically(file_paths) do
    file_paths |> Enum.sort
  end

  defp prepend_dir_path(file_paths, dir_path) do
    file_paths |> Enum.map(fn(file_path) -> dir_path <> file_path  end)
  end
end
