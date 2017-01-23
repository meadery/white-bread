defmodule WhiteBread.Outputers.Console do
  use GenServer
  alias WhiteBread.Outputers.Style

  # defstruct pid: nil

  ## Client Interface

  @doc false
  def start do
    {:ok, outputer} = GenServer.start __MODULE__, []
    outputer
  end

  @doc false
  def stop(outputer) do
    GenServer.cast(outputer, :stop)
  end

  ## Interface to Generic Server Machinery

  def init([]) do
    Process.flag(:trap_exit, true)
    {:ok, []}
  end

  def handle_cast({:suite, name}, state) when is_binary(name) do
    IO.puts("\n\nSuite: #{name}")
    {:noreply, state}
  end
  def handle_cast({:scenario_result, result, scenario}, state) do
    output_scenario_result(result, scenario)
    {:noreply, state}
  end
  def handle_cast({:final_results, results}, state) do
    output_final_results(results)
    {:noreply, state}
  end
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end
  def handle_cast(x, state) do
    require Logger

    Logger.warn "cast with #{inspect x}."
    {:noreply, state}
  end

  ## Internal

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
