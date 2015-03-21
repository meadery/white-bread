defmodule WhiteBread.TablesTest do
  use ExUnit.Case


  test "Can index a row by a header row" do
    headings = ["number_one", "number_two"]
    row      = ["one",        "two"]
    assert WhiteBread.Tables.index_row_with_headings(row, headings) == %{number_one: "one", number_two: "two"}
  end

  test "Can index a whole table by the first row" do
    table = [
      ["number_one", "number_two"],
      ["one",        "two"],
      ["next_one",   "next_two"]
    ]
    assert WhiteBread.Tables.index_table_by_first_row(table) == [
      %{number_one: "one", number_two: "two"},
      %{number_one: "next_one", number_two: "next_two"},
    ]
  end

end
