defmodule WhiteBread.Tags.FiltererTest do
  use ExUnit.Case
  import WhiteBread.Tags.Filterer

  test "Filters for single tag" do
    items = [%{tags: ["a", "b"]}, %{tags: ["a", "e"]}, %{tags: ["b"]}]
    assert filter(items, ["b"]) == [%{tags: ["a", "b"]}, %{tags: ["b"]}]
    assert filter(items, ["a"]) == [%{tags: ["a", "b"]}, %{tags: ["a", "e"]}]
  end

  test "Filters for multiple tags using OR" do
    items = [%{tags: ["a", "b"]}, %{tags: ["c", "d"]}, %{tags: ["e", "f"]}]
    assert filter(items, ["a", "e"]) == [%{tags: ["a", "b"]}, %{tags: ["e", "f"]}]
    assert filter(items, ["d", "f"]) == [%{tags: ["c", "d"]}, %{tags: ["e", "f"]}]
  end

end
