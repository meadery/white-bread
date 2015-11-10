defmodule WhiteBread.Formatter.FailedStep do
  alias WhiteBread.CodeGenerator

  def text({:missing_step, step, _error}) do
    %{text: step_text} = step
    code_to_implement = CodeGenerator.Step.regex_code_for_step(step)
    "undefined step: #{step_text} implement with\n\n" <> code_to_implement
  end

  def text({:no_clause_match, step, error}) do
    %{text: step_text} = step
    {_clause_match_error, stacktrace} = error
    trace_message = Exception.format_stacktrace(stacktrace)
    "unable to match clauses: #{step_text}:\ntrace:\n#{trace_message}"
  end

  def text({:assertion_failure, step, assertion_failure}) do
    %{text: step_text} = step
    %{message: assestion_message} = assertion_failure
    "#{step_text}: #{assestion_message}"
  end

  def text({:other_failure, step, {other_failure, stacktrace}}) do
    %{text: step_text} = step
    trace_message = Exception.format_stacktrace(stacktrace)
    "execution failure: #{step_text}:\n" <>
    "Exception: #{Exception.message other_failure}: \n" <>
    "#{trace_message}"
  end
end
