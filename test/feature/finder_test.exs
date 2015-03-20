defmodule WhiteBread.Feature.FinderTest do
  use ExUnit.Case

  test "finds only the two feature files" do
    result = WhiteBread.Feature.Finder.find_in_path("features/")
    assert result == ["features/example1.feature", "features/sub_folder/example2.feature", "features/table_example.feature"]
  end

end
