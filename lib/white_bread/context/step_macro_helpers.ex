defmodule WhiteBread.Context.StepMacroHelpers do

  def step_name({:sigil_r, _, [{_, _, [string]}, _]}) do
    String.to_atom("regex_step_" <> string)
  end
  def step_name(step_text) do
    String.to_atom("step_" <> step_text)
  end

end
