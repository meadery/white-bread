defmodule WhiteBread.Suite.ContextPerFeature do
  alias WhiteBread.Suite
  alias WhiteBread.Feature.Finder

  @feature_ext ".feature"
  @context_suffix "Context"

  def build_suites(namespace_prefix: prefix, entry_path: entry_path) do
    build_suites(
      namespace_prefix: prefix,
      entry_path: entry_path,
      extra_config: []
    )
  end

  def build_suites(
    namespace_prefix: prefix,
    entry_path: entry_path,
    extra_config: extra_config
  ) do
    entry_path
      |> Finder.find_in_path
      |> Enum.map(fn path ->
          build_suite(namespace_prefix: prefix, file: path)
      end)
      |> Enum.map(&WhiteBread.Suite.set_properties(&1, extra_config))
  end

  def build_suite(namespace_prefix: prefix, file: file_path)
  when is_binary(file_path)
  do
    file_name = Path.basename(file_path, @feature_ext)
    module = make_module_name(file_name)
    %Suite{
      name: module,
      context: Module.concat([
        prefix,
        module <> @context_suffix]),
      feature_paths: [file_path]
    }
  end

  defp make_module_name(file_name) do
    file_name
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join()
  end

end
