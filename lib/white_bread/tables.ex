defmodule WhiteBread.Tables do

  def index_table_by_first_row([]) do
    []
  end

  def index_table_by_first_row(table) do
    [headers] = table |> Enum.take(1)

    table
    |> Stream.drop(1)
    |> Enum.map(fn(row) -> index_row_with_headings(row, headers) end)
  end

  def index_row_with_headings(row, header_row) do
    row
    |> Stream.with_index
    |> Stream.map(fn({content, position}) -> {content, Enum.at(header_row, position)} end)
    |> Stream.map(fn({content, key}) -> {content, String.to_atom(key)} end)
    |> Enum.reduce(%{}, fn({value, index}, dict) -> dict |> Dict.put(index, value) end)
  end


end
