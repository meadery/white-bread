defimpl WhiteBread.Runners, for: WhiteBread.Gherkin.Elements.ScenarioOutline do
  def run(scenario_outline, context, background_steps) do

    scenario_outline
    |> build_individual_step_collections
    |> Enum.map(fn(steps) -> WhiteBread.Runners.run(steps, context, background_steps) end)
    |> Enum.map(fn
           ({:ok, _last_state}) -> {:ok, scenario_outline.name}
           (error_data)         -> {:failed, error_data}
       end)
  end

  defp build_individual_step_collections(outline) do
    outline.examples
    |> WhiteBread.Tables.index_table_by_first_row
    |> Enum.map(fn(example) -> outline.steps |> update_steps_with_example(example) end)
  end

  defp update_steps_with_example(steps, example) do
    steps
    |> Enum.map(fn(step) -> update_step_with_example(step, example) end)
  end

  defp update_step_with_example(starting_step, example) do
    example
    |> Enum.reduce(starting_step, fn({replace, value}, step) -> replace_in_step(step, replace, value)  end)
  end

  defp replace_in_step(%{text: initial} = step, replace, with) do
    updated_text = initial |> String.replace("<#{to_string(replace)}>", with)
    %{step | text: updated_text}
  end

end
