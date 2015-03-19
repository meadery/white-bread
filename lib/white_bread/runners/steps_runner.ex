defimpl WhiteBread.Runners, for: List do
  def run(steps, context) do
    starting_state = context |> get_starting_state

    reduction = fn
      (step, {:ok, state})                            -> run_step(context, step, state)
      (_step, {fail_reason, failing_step, error})     -> {fail_reason, failing_step, error}
      (_step, bad_state)                              -> bad_state
    end

    result = steps |> Enum.reduce({:ok, starting_state}, reduction)
  end

  defp run_step(context, step, state) do
    apply(context, :execute_step, [step, state])
  end

  defp get_starting_state(context) do
    apply(context, :starting_state, [])
  end

end
