defmodule WhiteBread.Outputers.HTMLTests do
	use ExUnit.Case
  alias WhiteBread.Outputers.HTML
  alias WhiteBread.Gherkin.Elements.Scenario

  @console WhiteBread.Outputers.Console

  test "default outputer is for the console" do
     assert @console = Application.fetch_env! :white_bread, :outputer
  end

  test "file path fetched on initialization" do
    old = Application.fetch_env! :white_bread, :path
    :ok = Application.put_env :white_bread, :path, "/fu/bar.baz"
    assert {:ok, %HTML{path: "/fu/bar.baz"}} = HTML.init []
    :ok = Application.put_env :white_bread, :path, old
  end

  test "success result stored with the scenario name" do
    assert {:noreply, %HTML{data: [{:ok, "X"}]}} ==
      HTML.handle_cast {:scenario_result, {:ok, "ignore"}, %Scenario{name: "X"}}, %HTML{data: []}
  end

  test "write file on termaination" do
    p = Path.expand("~/report.html")
    HTML.terminate :normal, %HTML{path: p, data: [{:ok, "X"}]}
    s = File.stat! p
    assert File.exists? p
    assert s.size > 0
    File.rm! p
  end
end
