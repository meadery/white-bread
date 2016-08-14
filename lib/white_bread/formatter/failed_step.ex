defprotocol WhiteBread.Formatter.FailedStep do
  def text(failure_type, failing_step, failure_data)
end

defimpl WhiteBread.Formatter.FailedStep, for: Atom do
  alias WhiteBread.CodeGenerator
  alias WhiteBread.Outputers.Style

  def text(:missing_step, step, _error) do
    %{text: step_text} = step
    code_to_implement = CodeGenerator.Step.regex_code_for_step(step)
    Style.info "undefined step: #{step_text}"
    <> " implement with\n\n" <> code_to_implement
  end

  def text(:no_clause_match, step, error) do
    %{text: step_text} = step
    {_clause_match_error, stacktrace} = error
    trace_message = Exception.format_stacktrace(stacktrace)
    Style.failed "unable to match clauses: #{step_text}:\n" <>
    "trace:\n#{trace_message}"
  end

  def text(:other_failure, step, {other_failure, stacktrace}) do
    %{text: step_text} = step
    trace_message = Exception.format_stacktrace(stacktrace)
    "execution failure: #{step_text}:\n" <>
    Style.exception "Exception: #{Exception.message other_failure}: \n" <>
    trace_message
  end
end

defimpl WhiteBread.Formatter.FailedStep,
for: [ESpec.AssertionError, ExUnit.AssertionError] do
  def text(_, step, assertion_failure) do
    print_assertion_failure assertion_failure
    %{text: step_text} = step
    %{message: assestion_message} = assertion_failure
    "#{step_text}: #{assestion_message}"
  end

  defp print_assertion_failure(assertion_failure) do
    msg = ExUnit.AssertionError.message(assertion_failure)
    formatted = [:red | msg]
                |> IO.ANSI.format(true)
                |> IO.iodata_to_binary
    IO.puts formatted
  end
end
