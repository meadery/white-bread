defmodule WhiteBread.SuiteConfiguration do
  alias WhiteBread.Suite.DuplicateSuiteError

  defmacro __using__(_opts) do
    quote do
      import WhiteBread.SuiteConfiguration

      @config_context_per_feature %WhiteBread.ContextPerFeature{}
      @suites []
      @before_compile WhiteBread.SuiteConfiguration
    end
  end

  defmacro __before_compile__(_env) do
    quote do

      def context_per_feature do
        @config_context_per_feature
      end

      def suites do
        unique!(@suites)
      end

      defp unique!(suites) do
        unique? = suites
          |> Stream.map(fn suite -> suite.name end)
          |> Enum.uniq
          |> same_size?(suites)
        unless unique? do
          raise DuplicateSuiteError
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
    on:                 on,
    namespace_prefix:   namespace_prefix,
    entry_feature_path: entry_feature_path) do
    quote do
      @config_context_per_feature %WhiteBread.ContextPerFeature{
        on: unquote(on),
        namespace_prefix: unquote(namespace_prefix),
        entry_feature_path: unquote(entry_feature_path)
      }
    end
  end

end
