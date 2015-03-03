defmodule WhiteBread.Feature.Finder do
  import String, only: [ends_with?: 2]

  def find_in_path(dir_path) do
    File.ls!(dir_path)
    |> get_only_feature_files
    |> prepend_dir_path(dir_path)
  end

  defp get_only_feature_files(file_paths) do
    file_paths |> Enum.filter(fn(file_path) -> file_path |> ends_with? ".feature" end)
  end

  defp prepend_dir_path(file_paths, dir_path) do
    file_paths |> Enum.map(fn(file_path) -> dir_path <> file_path  end)
  end
end
