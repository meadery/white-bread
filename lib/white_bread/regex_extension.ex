defmodule WhiteBread.RegexExtension do

  def atom_keyed_named_captures(regex, string) do
    captures = Regex.named_captures(regex, string)
    captures
    |> Dict.keys
    |> Enum.map(fn(key) -> {String.to_atom(key), Dict.get(captures, key)} end)
  end
end
