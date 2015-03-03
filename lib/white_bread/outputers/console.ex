defmodule WhiteBread.Outputers.Console do

  def start do
    spawn fn -> work end
  end

  def stop(pid) do
    send pid, {:stop}
  end

  defp work do
    continue = receive do
      {:scenario_result, result, scenario, feature} -> output_scenario_result(result, scenario, feature)
      {:stop} -> :stop
    end
    unless continue == :stop, do: work
  end

  defp output_scenario_result({result, _result_info}, scenario, _feature) do
    IO.puts "#{scenario.name} ---> #{result}"
    :ok
  end

end
