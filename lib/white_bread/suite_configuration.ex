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
        @suites
          |> unique!
          |> Enum.reverse
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
      @suites [new_suite | @suites]
    end
  end

end
