defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  @shortdoc "Runs all the feature files with WhiteBread"

  def run(argv) do
    {options, arguments, _} = OptionParser.parse(argv)

    case argv do
      [context_name | _ ] -> run(context_name, options)
      [] -> Mix.raise "Expected context module to be given. Use `mix white_bread.run Context`"
    end

  end

  def run(context_name, _options) do
    {context, []} = Code.eval_string(context_name)
    WhiteBread.run(context)
  end

end
