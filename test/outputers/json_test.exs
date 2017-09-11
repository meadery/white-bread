defmodule WhiteBread.Outputers.JSONTests do
  use ExUnit.Case
  alias WhiteBread.Outputers.JSON

  test "file path fetched on initialization" do
    old = Application.fetch_env! :white_bread, :outputers
    :ok = Application.put_env :white_bread, :outputers, [{JSON, path: "/fu/bar.baz"}]
    assert {:ok, %JSON{path: "/fu/bar.baz"}} = JSON.init []
    :ok = Application.put_env :white_bread, :outputers, old
  end

  test "write file on termaination" do
    p = Path.expand("~/fu/report.json")
    JSON.terminate :normal, %JSON{path: p, data: [%{id: "feature-id"}]}
    assert {:ok, s} = File.stat p
    assert s.size > 0
    File.rm! p
  end
end
