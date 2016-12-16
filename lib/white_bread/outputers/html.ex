defmodule WhiteBread.Outputers.HTML do
  use GenServer
  alias WhiteBread.Gherkin.Elements.Scenario
  alias WhiteBread.Gherkin.Elements.ScenarioOutline
  alias WhiteBread.Outputers.HTML.Formatter

  @moduledoc """
  This generic server accumulates information about White Bread
  scenarios then formats them as HTML and outputs them to a file in
  one go.
  """

  defstruct pid: nil, path: nil, data: []

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

  def init(_) do
    {:ok, %__MODULE__{path: path()}}
  end

  def handle_cast({:scenario_result, {result, _}, %Scenario{name: name}}, state) when :ok == result or :failed == result do
    {:noreply, %{ state | data: [ {result, name} | state.data ]}}
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

  def terminate(_, state) do
    import WhiteBread.Outputers.HTML.Formatter

    Enum.map(state.data, &format/1)
    |> list
    |> body
    |> document
    |> write(state.path)
  end

  ## Internal

  defp path, do: Path.expand Application.fetch_env! :white_bread, :path

  defp format({:ok,     name}), do: Formatter.success(name)
  defp format({:failed, name}), do: Formatter.failure(name)

  defp write(content, path) do
    File.mkdir_p!(parent path) && (File.write! path, content)
  end

  defp parent(path) do
    x = Path.split path
    Path.join x -- [ List.last(x) ]
  end
end
