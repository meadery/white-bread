defmodule WhiteBread.CommandLine.ContextPerFeature do
  alias WhiteBread.Suite
  alias WhiteBread.ContextPerFeature
  alias WhiteBread.Feature.Finder
  @feature_ext ".feature"
  @context_suffix "Context"

  def build_suites(%ContextPerFeature{} = context_per_feature) do
    cond do
      context_per_feature.on == true ->
        {:ok, Finder.find_in_path(context_per_feature.entry_feature_path) |>
          Enum.map(fn path -> 
            build_suite(context_per_feature, path)
          end)
        }
      context_per_feature.on == false ->
        {:error, "Context per feature not on"}
    end
  end

  def build_suites(_invalid), do: {:error, "Not a valid context per feature"}

  def build_suite(%ContextPerFeature{} = context_per_feature, file_path) when is_binary(file_path) do
    file_name = Path.basename(file_path, @feature_ext)
    module = make_module_name(file_name)
    %Suite{
      name: module,
      context: Module.concat([context_per_feature.namespace_prefix, module <> @context_suffix]),
      feature_paths: [file_path]
    }
  end

  defp make_module_name(file_name) do
    String.split(file_name, "_") |>
    Enum.map(&String.capitalize/1) |>
    Enum.join()
  end

end