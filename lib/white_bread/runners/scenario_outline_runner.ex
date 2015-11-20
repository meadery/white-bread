defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.ScenarioOutline do
  alias WhiteBread.Outputers.ProgressReporter

  def run(scenario_outline, context, setup) do
    scenario_outline
      |> build_each_example
      |> Enum.map(&WhiteBread.Runners.run(&1, context, setup))
      |> Enum.map(&process_result(&1, scenario_outline))
      |> report_progress(setup, scenario_outline)
  end

  defp process_result({:ok, _last_state}, scenario), do: {:ok, scenario.name}
  defp process_result(error_data,        _scenario), do: {:failed, error_data}

  defp build_each_example(outline) do
    outline.examples
      |> WhiteBread.Tables.index_table_by_first_row
      |> Enum.map(&create_steps(&1, outline.steps))
  end

  defp create_steps(example, step_outlines) do
    step_outlines
      |> Enum.map(&update_step_using_example(&1, example))
  end

  defp update_step_using_example(starting_step, example) do
    example
      |> Enum.reduce(starting_step, &replace_in_step/2)
  end

  defp replace_in_step({replace, with}, step) do
    %{text: initial} = step
    updated_text = initial
      |> String.replace("<#{to_string(replace)}>", with)
    %{step | text: updated_text}
  end

  defp report_progress(results, setup, scenario_outline) do
    failures? = results |> Enum.any?(fn {success, _} -> success != true end)
    success_status = if failures?, do: :failed, else: :ok
    scenario_report ={:scenario_result, {success_status, nil}, scenario_outline}
    setup.progress_reporter
      |> ProgressReporter.report(scenario_report)
    results
  end

end
