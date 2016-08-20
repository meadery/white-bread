defmodule WhiteBread.Tables do

  def index_table_by_first_row([]) do
    []
  end

  def index_table_by_first_row(table) do
    [headers] = table |> Enum.take(1)

    table
    |> Stream.drop(1)
    |> Enum.map(&index_row_with_headings(&1, headers))
  end

  def index_row_with_headings(row, header_row) do
    row
      |> Stream.with_index
      |> Stream.map(&get_header(&1, header_row))
      |> Stream.map(&header_string_to_atom/1)
      |> Enum.reduce(%{}, &build_indexed_row/2)
  end

  defp get_header({content, position}, header_row) do
    {content, Enum.at(header_row, position)}
  end

  defp header_string_to_atom({content, header_string})
  when is_bitstring header_string do
    {content, String.to_atom(header_string)}
  end

  defp build_indexed_row({value, index}, indexed_row) do
    indexed_row |> Dict.put(index, value)
  end

end
