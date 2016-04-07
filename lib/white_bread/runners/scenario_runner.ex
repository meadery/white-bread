defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.Scenario do
  alias WhiteBread.Outputers.ProgressReporter

  def run(scenario, context, setup) do
    trap_exits
    setup_with_state = setup
      |> update_setup_starting_state(context)
    scenario.steps
      |> WhiteBread.Runners.run(context, setup_with_state)
      |> update_result_with_exits
      |> stop_trapping_exits
      |> make_tuple(scenario)
      |> output_result(setup.progress_reporter, scenario)
  end

  defp update_setup_starting_state(setup, context) do
    Map.update!(setup, :starting_state, fn feature_state ->
      apply(context, :starting_state, [feature_state])
    end)
  end

  defp make_tuple(result, scenario) do
    case result do
      {:ok, _}   -> {:ok, scenario.name}
      error_data -> {:failed, error_data}
    end
  end

  defp output_result(result_tuple, progress_reporter, scenario) do
    progress_reporter
      |> ProgressReporter.report({:scenario_result, result_tuple, scenario})
    result_tuple
  end

  defp trap_exits(pass_through \\ nil) do
    Process.flag(:trap_exit, true)
    pass_through
  end

  defp stop_trapping_exits(pass_through \\ nil) do
    Process.flag(:trap_exit, false)
    pass_through
  end

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
