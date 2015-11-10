defimpl WhiteBread.Runners, for: List do
  def run(steps, context, background_steps, global_starting_state) do

    starting_state = context |> update_starting_state(global_starting_state)

    try do
      background_steps
        |> Enum.concat(steps)
        |> Enum.reduce({:ok, starting_state}, step_executor(context))
    after
      context.finalize()
    end
  end

  defp step_executor(context) do
    fn
      (step, {:ok, state})
        -> run_step(context, step, state)
      (_step, failure_state)
        -> failure_state
    end
  end

  defp run_step(context, step, state) do
    apply(context, :execute_step, [step, state])
  end

  defp update_starting_state(context, global_starting_state) do
    apply(context, :starting_state, [global_starting_state])
  end

end
