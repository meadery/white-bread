defmodule WhiteBread.Outputers.HTMLTests do
	use ExUnit.Case
  alias WhiteBread.Outputers.HTML
  alias WhiteBread.Gherkin.Elements.Scenario

  test "default outputer is for the console" do
     assert WhiteBread.Outputers.Console = Application.fetch_env! :white_bread, :outputer
  end

  test "success result stored with the scenario name" do
    assert {:noreply, [{:ok, "X"}]} ==
      HTML.handle_cast {:scenario_result, {:ok, "ignore"}, %Scenario{name: "X"}}, []
  end
end
