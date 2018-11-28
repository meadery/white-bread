defmodule WhiteBread.Runners.ScenarioOutlineRunner do
  import WhiteBread.Runners.Utilities

  alias WhiteBread.Runners.Setup

  alias WhiteBread.Runners.StepsRunner

  def run(scenario_outline, context, %Setup{} = setup \\ Setup.new) do
    scenario_outline
      |> build_each_example
      |> Enum.map(&run_steps(&1, scenario_outline, context, setup))
      |> process_results(scenario_outline)
      |> report_progress(scenario_outline)
  end

  defp process_results([], _), do: [{:failed, :no_examples_given}]
  defp process_results(results, scenario_outline) do
    Enum.map(results, &process_result(&1, scenario_outline))
  end

  defp process_result({:ok, _last_state}, scenario), do: {:ok, scenario.name}
  defp process_result(error_data,        _scenario), do: {:failed, error_data}

  defp build_each_example(outline) do
    outline.examples
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

  defp run_steps(steps, scenario_outline, context, %Setup{} = setup) when is_list(steps) do
    starting_state = setup.starting_state
      |> apply_scenario_starting_state(context)

    StepsRunner.run(
      {scenario_outline, steps}, context, setup.background_steps, starting_state
    )
  end

  defp replace_in_step({replace, with}, step) do
    %{text: initial_text, table_data: initial_table} = step
    placeholder = "<#{to_string(replace)}>"
    updated_text = initial_text
      |> String.replace(placeholder, with)

    updated_table = for row <- initial_table do
      for {key, value} <- row, into: %{} do
        key = key |> Atom.to_string |> String.replace(placeholder, with) |> String.to_atom
        value = String.replace(value, placeholder, with)

        {key, value}
      end
    end

    %{step | text: updated_text, table_data: updated_table}
  end

  defp report_progress(results, scenario_outline) do
    failures? = results |> Enum.any?(fn {success, _} -> success != :ok end)
    success_status = if failures?, do: :failed, else: :ok
    scenario_report ={:scenario_result, {success_status, nil},
    scenario_outline}
    WhiteBread.Outputer.report(scenario_report)
    results
  end

end
