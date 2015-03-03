defmodule WhiteBread.Context.StepExecutor do

  def execute_step({string_steps, regex_steps}, %{text: step_text} = step, state) do
    try do
      if (Dict.has_key?(string_steps, step_text)) do
        function = Dict.fetch!(string_steps, step_text)
        apply(function, [state])
      else
        regex_steps |> apply_regex_function(step_text, state)
      end
    rescue
      assertion_error in ExUnit.AssertionError        -> {:fail, assertion_error}
      _missing_step in WhiteBread.Context.MissingStep -> {:missing_step, step}
      _clause_match_error in FunctionClauseError      -> {:no_clause_match, step}
    end
  end

  defp apply_regex_function(regex_steps, step_text, state) do
    {regex, function} = regex_steps |> find_regex_and_function(step_text)
    args = unless Regex.names(regex) == [] do
      captures = WhiteBread.RegexExtension.atom_keyed_named_captures(regex, step_text)

      [state, captures]
    else
      [state]
    end
    apply(function, args)
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
