defmodule WhiteBread.Outputers.HTMLTests do
	use ExUnit.Case

  test "default outputer is for the console" do
     assert WhiteBread.Outputers.Console = Application.fetch_env! :white_bread, :outputer
  end
end
