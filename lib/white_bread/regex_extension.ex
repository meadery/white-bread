defmodule WhiteBread.RegexExtension do

  @doc ~S"""
  Takes a regex and matches it against the string. Returns named groups
  with atoms as keys.

  ## Examples

      iex> atom_keyed_named_captures(~r/hello (?<world>[a-z]+)/, "hello earth")
      %{world: "earth"}

      iex> atom_keyed_named_captures(~r/(?<a>[a-z]+) (?<b>[a-z]+)/, "hello earth")
      %{a: "hello", b: "earth"}

      iex> atom_keyed_named_captures(~r/.+/, "hello earth")
      %{}

  """
  def atom_keyed_named_captures(regex, string) do
    regex
      |> Regex.named_captures(string)
      |> Enum.map(fn({key, value}) -> {String.to_atom(key), value} end)
      |> Enum.into(%{})
  end
end
