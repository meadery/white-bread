defmodule WhiteBread.Context.StepExecutor do
  alias WhiteBread.RegexExtension
  alias WhiteBread.Context.StepExecutor.ErrorHandler
  alias WhiteBread.Context.StepFunction

  def execute_step(steps, step, state) when is_list(steps) do
    try do
      step_func = find_match(steps, step.text)
      case StepFunction.type(step_func) do
        :string -> apply_string_function(step_func, step, state)
        :regex -> apply_regex_function(step_func, step, state)
      end
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

  defp apply_regex_function(regex_def, step, state) do
    key_matches = RegexExtension.atom_keyed_named_captures(
      regex_def.regex,
      step.text
    )
    extra = Map.new
      |> Dict.merge(key_matches)
      |> Dict.put(:table_data, step.table_data)
      |> Dict.put(:doc_string, step.doc_string)
    apply(regex_def.function, [state, extra])
  end

  defp apply_string_function(string_def, step, state) do
    args = [state, {:table_data, step.table_data}]
    apply(string_def.function, args)
  end

end
