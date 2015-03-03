defmodule WhiteBread.ScenarioRunner do

  def run(context, scenario) do

    reduction = fn
      (step, {:ok, state})                      -> run_step(context, step, state)
      (_step, {:missing_step, missing_step})    -> {:missing_step, missing_step}
      (_step, {:no_clause_match, failing_step}) -> {:no_clause_match, failing_step}
    end

    result = scenario.steps
    |> Enum.reduce({:ok, :start}, reduction)

    case result do
      {:ok, _}                 -> {:ok, scenario.name}
      {:missing_step, step}    -> {:failed, {:missing_step, step}}
      {:no_clause_match, step} -> {:failed, {:no_clause_match, step}}
      _                        -> {:failed, :unknown}
    end
  end

  defp run_step(context, step, state) do
    apply(context, :execute_step, [step, state])
  end

end
