defmodule WhiteBread.Runners.StepsRunner do
  alias WhiteBread.Context.StepExecutor

  def run(steps, context, background_steps, starting_state)
  when is_list(steps) and is_list(background_steps)
  do
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

  defp run_step(context, step, state) do
    possible_steps = apply(context, :get_steps, [])
    result = StepExecutor.execute_step(possible_steps, step, state)
    case result do
      {:ok, state} -> {:ok, state}
      :ok          -> {:ok, state}
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
