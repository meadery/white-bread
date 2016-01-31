defmodule WhiteBread.Step do
  alias WhiteBread.Context.StepFunction

  def given_(text, func), do: StepFunction.new(text, func)
  def when_(text, func),  do: StepFunction.new(text, func)
  def then_(text, func),  do: StepFunction.new(text, func)
  def and_(text, func),   do: StepFunction.new(text, func)
  def but_(text, func),   do: StepFunction.new(text, func)

  def _(text, func),      do: StepFunction.new(text, func)

end
