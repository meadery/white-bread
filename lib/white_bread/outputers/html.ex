defmodule WhiteBread.Outputers.HTML do
  use GenServer
  alias WhiteBread.Gherkin.Elements.Scenario
  alias WhiteBread.Gherkin.Elements.ScenarioOutline

  @moduledoc """
  This generic server accumulates information about White Bread
  scenarios then formats them as HTML and outputs them to a file in
  one go.
  """

  defstruct pid: nil

  ## Client Interface

  def start do
    {:ok, outputer} = GenServer.start __MODULE__, []
    %__MODULE__{pid: outputer}
  end

  def stop(%__MODULE__{pid: outputer}) do
    :ok = GenServer.stop outputer, :normal, 2 * 1000
  end

  def report(%__MODULE__{pid: outputer}, report) do
    GenServer.cast outputer, report
  end

  ## Interface to Generic Server Machinery

  def handle_cast({:scenario_result, {result, _}, %Scenario{name: name}}, state) when :ok == result or :failed == result do
    {:noreply, [ {result, name} | state ]}
  end

  def handle_cast({:scenario_result, {_, _}, %ScenarioOutline{}}, state) do
    {:noreply, state}
  end

  def handle_cast({:final_results, %{successes: _, failures: _}}, state) do
    {:noreply, state}
  end

  def handle_cast(x, state) do
    require Logger
    Logger.warn "casted with #{inspect x}."
    {:noreply, state}
  end
end
