defmodule WhiteBread.Formatter.FailedStep do

  def text({:missing_step, %{text: step_text} = step, _error}) do
    code_to_implement = WhiteBread.CodeGenerator.Step.regex_code_for_step(step)
    "undefined step: #{step_text} implement with\n\n" <> code_to_implement
  end

  def text({:no_clause_match, %{text: step_text}, {clause_match_error, stacktrace}}) do
    trace_message = Exception.format_stacktrace(stacktrace)
    "unable to match clauses: #{step_text}:\n trace:\n #{trace_message}"
  end

  def text({:assertion_failure, %{text: step_text}, assertion_failure}) do
    %{message: assestion_message} = assertion_failure
    "#{step_text}: #{assestion_message}"
  end

end
