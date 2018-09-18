defmodule WhiteBread.Step do
  alias WhiteBread.Context.StepFunction

  def def_given(text, func), do: StepFunction.new(text, func)
  def def_when(text, func),  do: StepFunction.new(text, func)
  def def_then(text, func),  do: StepFunction.new(text, func)
  def def_and(text, func),   do: StepFunction.new(text, func)
  def def_but(text, func),   do: StepFunction.new(text, func)

  def _(text, func),      do: StepFunction.new(text, func)

end
