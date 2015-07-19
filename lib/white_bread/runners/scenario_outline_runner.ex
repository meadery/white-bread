defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.ScenarioOutline do
  def run(scenario_outline, context, background_steps, starting_state) do
    setup = {context, background_steps, starting_state}
    scenario_outline
      |> build_individual_step_collections
      |> Enum.map(fn(steps) -> run(steps, setup) end)
      |> Enum.map(fn
             ({:ok, _last_state}) -> {:ok, scenario_outline.name}
             (error_data)         -> {:failed, error_data}
         end)
  end

  defp run(steps, {context, background_steps, starting_state}) do
    WhiteBread.Runners.run(steps, context, background_steps, starting_state)
  end

  defp build_individual_step_collections(outline) do
    steps = outline.steps
    outline.examples
      |> WhiteBread.Tables.index_table_by_first_row
      |> Enum.map(fn(example) -> steps |> update_with_example(example) end)
  end

  defp update_with_example(steps, example) do
    steps
      |> Enum.map(fn(step) -> update_step_with_example(step, example) end)
  end

  defp update_step_with_example(starting_step, example) do
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
