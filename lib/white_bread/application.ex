defmodule WhiteBread.Application do
  @moduledoc false

  use Application

  def start(_, _) do
    import Supervisor.Spec

    child = supervisor(WhiteBread.Supervisor, [])

    opts = [strategy: :one_for_one, name: WhiteBread.Supervisor]
    Supervisor.start_link([child], opts)
  end

  def stop() do
    WhiteBread.EventManager.stop()
  end
end
