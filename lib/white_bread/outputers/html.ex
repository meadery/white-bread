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

  @doc false
  def start do
    {:ok, outputer} = GenServer.start __MODULE__, []
    %__MODULE__{pid: outputer}
  end

  @doc false
  def stop(%__MODULE__{pid: outputer}) do
    :ok = GenServer.stop outputer, :normal, 2 * 1000
  end

  @doc "Interface function for the `ProgressReporter` protocol."
  def report(%__MODULE__{pid: outputer}, report) do
    GenServer.cast outputer, report
  end

  ## Interface to Generic Server Machinery

  def init(_) do
    {:ok, %__MODULE__{path: document_path()}}
  end

  def handle_cast({:scenario_result, {result, _}, %Scenario{name: name}}, state) when :ok == result or :failed == result do
    {:noreply, %{state | data: [{result, name}|state.data]}}
  end
  def handle_cast({:scenario_result, {_, _}, %ScenarioOutline{}}, state) do
    ## This clause here for more sophisticated report in the future.
    {:noreply, state}
  end
  def handle_cast({:final_results, %{successes: _, failures: _}}, state) do
    ## This clause here for more sophisticated report in the future.
    {:noreply, state}
  end
  def handle_cast(x, state) do
    require Logger

    Logger.warn "casted with #{inspect x}."
    {:noreply, state}
  end

  def terminate(_, %__MODULE__{data: content, path: path}) do
    report_ content, path
  end

  ## Internal

  defp document_path do
    case Application.fetch_env!(:white_bread, :path) do
      "/" ->
        raise WhiteBread.Outputers.HTML.PathError
      x when is_binary(x) ->
        Path.expand x
    end
  end

  defp format({:ok,     name}), do: Formatter.success(name)
  defp format({:failed, name}), do: Formatter.failure(name)

  defp write(content, path) do
    File.mkdir_p!(parent path) && File.write!(path, content)
  end

  defp parent(path) do
    Path.join(drop(Path.split path))
  end

  defp drop(x) when is_list(x), do: x -- [List.last(x)]

  defmodule PathError do
    defexception message: "Given root directory."
  end

  defp report_(content, path) do
    import Formatter, only: [list: 1, body: 1, document: 1]

    content
    |> Enum.map(&format/1)
    |> list
    |> body
    |> document
    |> write(path)
  end
end
