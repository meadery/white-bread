defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.ScenarioOutline do
  def run(scenario_outline, context, background_steps, starting_state) do
    setup = {context, background_steps, starting_state}
    scenario_outline
      |> build_each_example
      |> Enum.map(&run(&1, setup))
      |> Enum.map(&process_result(&1, scenario_outline))
  end

  defp run(steps, {context, background_steps, starting_state}) do
    WhiteBread.Runners.run(steps, context, background_steps, starting_state)
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

end
