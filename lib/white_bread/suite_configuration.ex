defmodule WhiteBread.SuiteConfiguration do

  defmacro __using__(_opts) do
    quote do
      import WhiteBread.SuiteConfiguration

      @suites []
      @before_compile WhiteBread.SuiteConfiguration
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def suites, do: @suites
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
    add_suite(name: name, context: context, feature_paths: paths, tags: [])
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
      @suites [new_suite | @suites]
    end
  end

end
