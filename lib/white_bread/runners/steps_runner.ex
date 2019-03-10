defmodule WhiteBread.Runners.StepsRunner do
  alias WhiteBread.Context.StepExecutor

  def run({scenario, steps}, context, background_steps, starting_state)
  when is_list(background_steps)
  do
    background_steps
      |> Enum.concat(steps)
      |> Enum.reduce({:ok, starting_state, []}, step_executor(context))
      |> finalize(context, scenario)
  end

  defp step_executor(context) do
    fn
      (step, {:ok, state, executed_steps})
        -> run_step(context, step, state, executed_steps)
      (_step, {error, state, executed_steps})
        -> {error, state, executed_steps}
    end
  end

  defp run_step(context, step, starting_state, executed_steps) do
    possible_steps = apply(context, :get_steps, [])
    result = StepExecutor.execute_step(possible_steps, step, starting_state)
    case result do
      {:ok, state, time} -> {:ok, state, [{step, time} | executed_steps]}
      {:ok, time}        -> {:ok, starting_state, [{step, time} | executed_steps]}
      error              -> {error, starting_state, executed_steps}
    end
  end

  defp finalize({:ok, state, _executed_steps}, context, scenario) do
    context.scenario_finalize({:ok, scenario}, state)
    {:ok, state}
  end
  defp finalize({error_result, state, _executed_steps}, context, scenario) do
    context.scenario_finalize({:error, error_result, scenario}, state)
    error_result
  end

end
