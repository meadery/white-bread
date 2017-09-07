defmodule WhiteBread.Runners.ScenarioRunner do
  import WhiteBread.Runners.Utilities

  alias WhiteBread.Runners.Setup

  alias WhiteBread.Runners.StepsRunner

  def run(scenario, context, %Setup{} = setup \\ Setup.new) do
    start_trapping_exits()

    starting_state = setup.starting_state
      |> apply_scenario_starting_state(context)

    {scenario, scenario.steps}
      |> StepsRunner.run(context, setup.background_steps, starting_state)
      |> update_result_with_exits
      |> stop_trapping_exits
      |> build_result_tuple(scenario)
      |> output_result(scenario)
  end

  defp build_result_tuple(result, scenario) do
    case result do
      {:ok, _}   -> {:ok, scenario.name}
      error_data -> {:failed, error_data}
    end
  end

  defp output_result(result_tuple, scenario) do
    WhiteBread.Outputer.report({:scenario_result, result_tuple, scenario})
    result_tuple
  end

  defp start_trapping_exits, do: Process.flag(:trap_exit, true)

  defp stop_trapping_exits(pass_through) do
    Process.flag(:trap_exit, false)
    pass_through
  end

  defp update_result_with_exits(result = {:other_failure, _, _}), do: result

  defp update_result_with_exits(result) do
    receive do
      {'DOWN', _ref, _process, _pid2, _reason} = exit_message ->
        {:exit_recieved, exit_message}
      {:EXIT, _pid, reason} = exit_message when reason != :normal ->
        {:exit_recieved, exit_message}
    after 0 ->
      result
    end
  end

end
