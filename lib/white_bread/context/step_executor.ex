defmodule WhiteBread.Context.StepExecutor do

  def execute_step({string_steps, regex_steps}, %{text: step_text} = step, state) do
    try do
      if (Dict.has_key?(string_steps, step_text)) do
        function = Dict.fetch!(string_steps, step_text)
        apply(function, [state, {:table_data, step.table_data}])
      else
        regex_steps |> apply_regex_function(step, state)
      end
    rescue
      assertion_error in ExUnit.AssertionError       -> {:assertion_failure, step, assertion_error}
      missing_step in WhiteBread.Context.MissingStep -> {:missing_step, step, missing_step}
      clause_match_error in FunctionClauseError      -> {:no_clause_match, step, {clause_match_error, System.stacktrace}}
    end
  end

  defp apply_regex_function(regex_steps, %{text: step_text, table_data: table_data}, state) do
    {regex, function} = regex_steps |> find_regex_and_function(step_text)
    key_matches = WhiteBread.RegexExtension.atom_keyed_named_captures(regex, step_text)

    extra = Map.new |> Dict.merge(key_matches)
    |> Dict.put(:table_data, table_data)
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
