defmodule WhiteBread.Context.StepExecutor do
  alias WhiteBread.RegexExtension

  defprotocol ErrorHandler do
    @fallback_to_any true
    def get_tuple(error, step, _stacktrace)
  end

  defimpl ErrorHandler, for: [Espec.AssertionError, ExUnit.AssertionError] do
    def get_tuple(error, step, _stacktrace) do
      {:assertion_failure, step, error}
    end
  end

  defimpl ErrorHandler, for: Any do
    def get_tuple(error, step, stacktrace) do
      {:other_failure, step, {error, stacktrace}}
    end
  end

  def execute_step({string_steps, regex_steps}, step, state) do
    %{text: step_text} = step
    try do
      if (Dict.has_key?(string_steps, step_text)) do
        function = Dict.fetch!(string_steps, step_text)
        apply(function, [state, {:table_data, step.table_data}])
      else
        regex_steps |> apply_regex_function(step, state)
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

  defp apply_regex_function(regex_steps, step, state) do
    %{text: step_text, table_data: table_data, doc_string: doc_string} = step
    {regex, function} = regex_steps |> find_regex_and_function(step_text)
    key_matches = RegexExtension.atom_keyed_named_captures(regex, step_text)

    extra = Map.new |> Dict.merge(key_matches)
    |> Dict.put(:table_data, table_data)
    |> Dict.put(:doc_string, doc_string)
    apply(function, [state, extra])
  end

  defp find_regex_and_function(regex_steps, string) do
    matches = regex_steps
    |> Stream.filter(fn {regex, _} -> Regex.run(regex, string) end)
    |> Enum.take(1)

    case matches do
      [{regex, function}] -> {regex, function}
      []                  -> raise WhiteBread.Context.MissingStep
    end
  end

end

