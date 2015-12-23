defmodule WhiteBread.Outputers.Console do
  defstruct pid: nil
  alias WhiteBread.Outputers.Style

  def start do
    pid = spawn fn -> work end
    %__MODULE__{pid: pid}
  end

  def stop(%__MODULE__{pid: pid}) do
    send pid, {:stop, self}
    receive do
      :stop_complete -> :ok
    after
      2_000 -> :ok
    end
  end

  defp work do
    continue = receive do
      {:scenario_result, result, scenario} ->
        output_scenario_result(result, scenario)
      {:final_results, results} ->
        output_final_results(results)
      {:stop, caller} ->
        send caller, :stop_complete
        :stop
      _ ->
        IO.puts "UNKOWN MESSAGE RECIEVED"
        :ok
    end
    unless continue == :stop, do: work
  end

  defp output_scenario_result({result, _result_info}, scenario) do
    IO.puts Style.decide_color result, "#{scenario.name} ---> #{result}"
    :ok
  end

  defp output_final_results(results) do
    results
      |> WhiteBread.FinalResultPrinter.text
      |> IO.puts
    :ok
  end

end
