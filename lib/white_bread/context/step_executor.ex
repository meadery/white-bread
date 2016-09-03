defmodule WhiteBread.Context.StepExecutor do
  alias WhiteBread.Context.StepExecutor.ErrorHandler
  alias WhiteBread.Context.StepFunction

  def execute_step(steps, step, state) when is_list(steps) do
    try do
      steps
        |> find_match(step.text)
        |> StepFunction.call(step, state)
    rescue
      missing_step in WhiteBread.Context.MissingStep
        -> {:missing_step, step, missing_step}
      clause_match_error in FunctionClauseError
        -> {:no_clause_match, step, {clause_match_error, System.stacktrace}}
      external_error
        -> ErrorHandler.get_tuple(external_error, step, System.stacktrace)
    end
  end

  defp find_match(steps, step_text) do
    matches = steps
      |> Stream.filter(&StepFunction.match?(&1, step_text))
      |> Enum.take(1)
    case matches do
      [match] -> match
      _       -> raise WhiteBread.Context.MissingStep
    end
  end

end
