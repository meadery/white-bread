defmodule WhiteBread.ScenarioRunner do

  def run(context, scenario) do
    run_steps(context, scenario.steps, scenario.name)
  end

  def run(context, scenario, [background_steps: background_steps]) do
    all_steps = scenario.steps |> Enum.into background_steps
    run_steps(context, all_steps, scenario.name)
  end

  defp run_steps(context, steps, scenario_name) do
    starting_state = context |> get_starting_state

    reduction = fn
      (step, {:ok, state})                            -> run_step(context, step, state)
      (_step, {fail_reason, failing_step, error})     -> {fail_reason, failing_step, error}
      (_step, bad_state)                              -> bad_state
    end

    result = steps |> Enum.reduce({:ok, starting_state}, reduction)

    case result do
      {:ok, _}   -> {:ok, scenario_name}
      error_data -> {:failed, error_data}
    end
  end

  defp run_step(context, step, state) do
    apply(context, :execute_step, [step, state])
  end

  defp get_starting_state(context) do
    apply(context, :starting_state, [])
  end

end
