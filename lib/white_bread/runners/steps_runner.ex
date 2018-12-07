defmodule WhiteBread.Runners.StepsRunner do
  alias WhiteBread.Context.StepExecutor

  def run({scenario, steps}, context, background_steps, starting_state)
  when is_list(background_steps)
  do
    background_steps
      |> Enum.concat(steps)
      |> Enum.reduce({:ok, {starting_state, %{}}}, step_executor(context))
      |> finalize(context, scenario)
  end

  defp step_executor(context) do
    fn
      (step, {:ok, {state, time_map}})
        -> run_step(context, step, state, time_map)
      (_step, failure_state)
        -> failure_state
    end
  end

  defp run_step(context, step, state, time_map) do
    possible_steps = apply(context, :get_steps, [])
    start = System.monotonic_time(:milli_seconds)
    result = StepExecutor.execute_step(possible_steps, step, state)
    time_spent = System.monotonic_time(:milli_seconds) - start
    time_map = Map.put(time_map, step.text, time_spent)
    case result do
      {:ok, state} -> {:ok, {state, time_map}}
      :ok          -> {:ok, {state, time_map}}
      error        -> {error, {state, time_map}}
    end
  end

  defp finalize(result = {:ok, {state, time_map}}, context, scenario) do
    context.scenario_finalize({:ok, scenario}, state)
    {result, time_map}
  end
  defp finalize({error_result, {state, time_map}}, context, scenario) do
    context.scenario_finalize({:error, error_result, scenario}, state)
    {error_result, time_map}
  end

end
