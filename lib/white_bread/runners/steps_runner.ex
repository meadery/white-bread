defimpl WhiteBread.Runners, for: List do
  def run(steps, context, background_steps, global_starting_state) do

    starting_state = context |> update_starting_state(global_starting_state)

    background_steps
      |> Enum.concat(steps)
      |> Enum.reduce({:ok, starting_state}, step_executor(context))
      |> finalize(context)

  end

  defp step_executor(context) do
    fn
      (step, {:ok, state})
        -> run_step(context, step, state)
      (_step, failure_state)
        -> failure_state
    end
  end

  defp update_starting_state(context, global_starting_state) do
    apply(context, :starting_state, [global_starting_state])
  end

  defp run_step(context, step, state) do
    result = apply(context, :execute_step, [step, state])
    case result do
      {:ok, state} -> {:ok, state}
      error        -> {error, state}
    end
  end

  defp finalize(result = {:ok, state}, context) do
    context.finalize(state)
    result
  end
  defp finalize({error_result, state}, context) do
    context.finalize(state)
    error_result
  end

end
