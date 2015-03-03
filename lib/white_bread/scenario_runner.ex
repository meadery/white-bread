defmodule WhiteBread.ScenarioRunner do

  def run(context, scenario) do

    reduction = fn
      (step, {:ok, state})                   -> run_step(context, step, state)
      (_step, {:missing_step, missing_step}) -> {:missing_step, missing_step}
    end

    result = scenario.steps
    |> Enum.reduce({:ok, :start}, reduction)

    case result do
      {:ok, _}              -> {:ok, scenario.name}
      {:missing_step, step} -> {:failed, {:missing_step, step}}
      _                     -> {:failed}
    end
  end

  defp run_step(context, step, state) do
    apply(context, :execute_step, [step, state])
  end

end
