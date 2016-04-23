defmodule WhiteBread.SuiteConfiguration do
  alias WhiteBread.Suite.DuplicateSuiteError

  defmacro __using__(_opts) do
    quote do
      import WhiteBread.SuiteConfiguration

      @suites []
      @before_compile WhiteBread.SuiteConfiguration
    end
  end

  defmacro __before_compile__(_env) do
    quote do

      def suites do
        unique!(@suites)
      end

      defp unique!(suites) do
        unique? = suites
          |> Stream.map(fn suite -> suite.name end)
          |> Enum.uniq
          |> same_size?(suites)
        unless unique? do
          raise_dupe_suite_error(suites)
        end
        suites
      end

      defp same_size?(a, b) do
        Enum.count(a) == Enum.count(b)
      end
    end
  end

  defmacro suite(properties) when is_list(properties) do
    add_suite(properties)
  end

  defp add_suite(properties) do
    quote do
      new_suite = %WhiteBread.Suite{}
        |> WhiteBread.Suite.set_properties(unquote(properties))
      @suites @suites ++ [new_suite]
    end
  end

  defmacro context_per_feature(namespace_prefix: prefix, entry_path: path) do
    create_context_per_feature(
      namespace_prefix: prefix,
      entry_path: path,
      extra: []
    )
  end

  defmacro context_per_feature(
    namespace_prefix: prefix,
    entry_path: path,
    extra: extra)
  do
    create_context_per_feature(
      namespace_prefix: prefix,
      entry_path: path,
      extra: extra
    )
  end

  defp create_context_per_feature(
    namespace_prefix: prefix,
    entry_path: path,
    extra: extra)
  do
    quote do
      new_suites = WhiteBread.Suite.ContextPerFeature.build_suites(
        namespace_prefix: unquote(prefix),
        entry_path: unquote(path),
        extra_config: unquote(extra)
      )
      @suites @suites ++ new_suites
    end
  end

  def raise_dupe_suite_error(suites) do
    dupes = suites
      |> Enum.group_by(fn suite -> suite.name end)
      |> Enum.map(fn {name, suites} -> {name, Enum.count(suites)} end)
      |> Enum.filter(fn {_, suites} -> suites > 1 end)
      |> Enum.map(fn {name, _} -> name end)
      |> Enum.join(", ")
    raise DuplicateSuiteError, message: "Duplicate suite names found: #{dupes}"
  end

end
