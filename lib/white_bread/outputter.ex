defmodule WhiteBread.Outputter do

  def report(thing) do
    WhiteBread.EventManager.report(thing)
  end

end
