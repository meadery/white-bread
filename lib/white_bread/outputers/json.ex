defmodule WhiteBread.Outputers.JSON do
  use GenServer

  @moduledoc """
  This generic server accumulates information about White Bread
  scenarios then formats them as JSON and outputs them to a file in
  one go.
  """

  defstruct path: nil, data: []

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

  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %__MODULE__{path: document_path()}}
  end

  def handle_cast({:final_results, results}, state) do
    all_features = results[:successes] ++ results[:failures]
    {:noreply, Map.put(state, :data, Enum.map(all_features, &map_feature/1))}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end
  def handle_cast(_x, state) do
    {:noreply, state}
  end

  def terminate(_, state = %__MODULE__{path: path}) do
    report(state, path)
  end

  ## Internal

  defp result_for_step(_step, {:ok, _name}) do
    %{
      status: "passed",
      duration: 1,
    }
  end

  defp result_for_step(step, {:failed, {error, failed_step, error2}}) do
    cond do
      step.line < failed_step.line -> %{status: "passed", duration: 1}
      step.line > failed_step.line -> %{status: "skipped", duration: 1}
      step.line == failed_step.line ->
        %{
          status: "failed",
          duration: 1,
          error_message: format_error_message(error, failed_step, error2)
        }
    end
  end

  defp format_error_message(error, _failed_step, {error_object, stacktrace}) when is_atom(error) do
    Exception.format(:error, error_object, stacktrace)
  end

  defp format_error_message(_error, _failed_step, assertion_error) do
    assertion_error.message
  end

  defp find_scenario_result(scenario, feature_result) do
    all_results = feature_result[:successes] ++ feature_result[:failures]
    Enum.find(all_results, fn({inner_scenario, _details}) ->
      inner_scenario.line == scenario.line && inner_scenario.name == scenario.name
    end)
  end

  defp step_keyword(%Gherkin.Elements.Steps.Given{}), do: "Given "
  defp step_keyword(%Gherkin.Elements.Steps.When{}), do: "When "
  defp step_keyword(%Gherkin.Elements.Steps.Then{}), do: "Then "
  defp step_keyword(%Gherkin.Elements.Steps.And{}), do: "And "
  defp step_keyword(%Gherkin.Elements.Steps.But{}), do: "But "

  defp normalize_name(name) do
    name
      |> String.downcase()
      |> String.replace(~r/\s/, "-")
  end

  defp document_path do
    case Keyword.fetch!(outputers(), __MODULE__) do
      [path: "/"] ->
        raise WhiteBread.Outputers.JSON.PathError
      [path: x] when is_binary(x) ->
        Path.expand x
    end
  end

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

  defp report(state, path) do
    state.data |> Poison.encode!(pretty: true, iodata: true) |> write(path)
  end

  defp outputers do
    Application.fetch_env!(:white_bread, :outputers)
  end

  defp map_feature({feature, result}) do
    %{
      id: normalize_name(feature.name),
      name: feature.name,
      uri: feature.file,
      keyword: "Feature",
      type: "scenario",
      line: feature.line,
      description: feature.description,
      elements: Enum.map(feature.scenarios, &(map_scenario(&1, feature, result))),
      tags: feature.tags |> Enum.map(fn(tag) -> %{name: tag, line: feature.line - 1} end),
    }
  end

  defp map_scenario(scenario, feature, feature_result) do
    scenario_result = find_scenario_result(scenario, feature_result)
    %{
      keyword: "Scenario",
      id: [feature.name, scenario.name] |> Enum.map(&normalize_name/1) |> Enum.join(";"),
      name: scenario.name,
      tags: scenario.tags |> Enum.map(fn(tag) -> %{name: tag, line: scenario.line - 1} end),
      steps: Enum.map(scenario.steps, &(map_step(&1, scenario_result))),
    }
  end

  defp map_step(step, scenario_result) do
    {_scenario, scenario_result_details} = scenario_result
    %{
      keyword: step_keyword(step),
      name: step.text,
      line: step.line,
      doc_string: %{
        content_type: "",
        value: step.doc_string,
        line: step.line + 1
      },
      match: %{},
      result: result_for_step(step, scenario_result_details),
    }
  end
end
