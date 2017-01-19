defmodule WhiteBread.EventManager do
  @moduledoc false

  ## An Event Manager inspired by that in ExUnit but adapted for
  ## WhiteBread.

  @timeout 30_000

  def start_link() do
    import Supervisor.Spec
    child = worker(GenServer, [], restart: :temporary)
    Supervisor.start_link([child], strategy: :simple_one_for_one, name: __MODULE__)
  end

  def stop() do
    for {_, pid, _, _} <- Supervisor.which_children(__MODULE__) do
      GenServer.stop(pid, :normal, @timeout)
    end
    Supervisor.stop(__MODULE__)
  end

  def add_handler(handler, opts) do
    Supervisor.start_child(__MODULE__, [handler, opts])
  end

  def report(details) do
    notify({:scenario_result, details})
  end

  defp notify(msg) do
    for {_, pid, _, _} <- Supervisor.which_children(__MODULE__) do
      GenServer.cast(pid, msg)
    end
    :ok
  end
end
