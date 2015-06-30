defmodule WhiteBread.RegexExtension do

  @doc ~S"""
  Takes a regex and matches it against the string. Returns named groups
  with atoms as keys.

  ## Examples

  iex> atom_keyed_named_captures(~r/hello (?<world>[a-z]+)/, "hello earth")
  [world: "earth"]

  iex> atom_keyed_named_captures(~r/(?<a>[a-z]+) (?<b>[a-z]+)/, "hello earth")
  [a: "hello", b: "earth"]

  iex> atom_keyed_named_captures(~r/.+/, "hello earth")
  []

  """
  def atom_keyed_named_captures(regex, string) do
    captures = Regex.named_captures(regex, string)
    captures
    |> Dict.keys
    |> Enum.map(fn(key) -> {String.to_atom(key), Dict.get(captures, key)} end)
  end
end
