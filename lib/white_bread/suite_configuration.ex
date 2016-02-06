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

  defmacro suite(
    name:          name,
    context:       context,
    feature_paths: paths,
    tags:          tags)
  do
    add_suite(name: name, context: context, feature_paths: paths, tags: tags)
  end

  defmacro suite(name: name, context: context, feature_paths: paths) do
    add_suite(name: name, context: context, feature_paths: paths, tags: nil)
  end

  defp add_suite(
    name:          name,
    context:       context,
    feature_paths: paths,
    tags:          tags)
  do
    quote do
      new_suite = %WhiteBread.Suite{
        name: unquote(name),
        context: unquote(context),
        feature_paths: unquote(paths),
        tags: unquote(tags)
      }
      @suites @suites ++ [new_suite]
    end
  end

  defmacro context_per_feature(
    namespace_prefix:   prefix,
    entry_feature_path: path)
  do
    quote do
      new_suites = WhiteBread.Suite.ContextPerFeature.build_suites(
        %{namespace_prefix: unquote(prefix), entry_feature_path: unquote(path)}
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
