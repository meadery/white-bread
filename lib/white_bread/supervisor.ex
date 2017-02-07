defmodule WhiteBread.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    supervise(children(), strategy: :one_for_one, name: __MODULE__)
  end

  defp children do
    [supervisor(WhiteBread.EventManager, [])]
  end
end
