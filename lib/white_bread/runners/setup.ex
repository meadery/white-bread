defmodule WhiteBread.Runners.Setup do
  defstruct [background_steps: [],
             starting_state: %{}]

  def new, do: %__MODULE__{}

  def new(background_steps: steps, state: state) do
    %__MODULE__{background_steps: steps, starting_state: state}
  end

  def new(background_steps: steps) do
    %__MODULE__{background_steps: steps}
  end

end
