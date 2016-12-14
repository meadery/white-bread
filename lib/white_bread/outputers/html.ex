defmodule WhiteBread.Outputers.HTML do
  use GenServer
  alias WhiteBread.Gherkin.Elements.Scenario

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

  def handle_cast({:scenario_result, {result, _}, %Scenario{name: n}}, state) do
    {:noreply, [ {result, n} | state ]}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end
end
