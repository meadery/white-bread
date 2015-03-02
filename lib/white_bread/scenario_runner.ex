defmodule WhiteBread.ScenarioRunner do

  def run(context, scenario) do
    result = scenario.steps
    |> Enum.reduce({:ok, :start}, fn(step, {:ok, state}) -> run_step(context, step, state) end)

    case result do
      {:ok, _} -> {:ok, scenario.name}
      _        -> {:fail}
    end
  end

  defp run_step(context, step, state) do
    apply(context, :execute_step, [step, state])
  end

end
