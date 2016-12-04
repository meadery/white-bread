defmodule WhiteBread.Feature.FinderTest do
  use ExUnit.Case
  alias WhiteBread.Feature.Finder

  test "finds only the five feature files" do
    result = Finder.find_in_path("features/default/")
    assert Enum.count(result) == 7
  end

  test "accepts a list of paths" do
    result = Finder.find_in_path(["features/default/sub_folder/", "features/default/sub_folder_two/"])
    assert Enum.count(result) == 2
  end

end
