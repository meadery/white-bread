defprotocol WhiteBread.Tags.Filterer do
  @fallback_to_any true

  @doc "Returns only items matching tags from the collection"
  def filter(collection, tags)

  @doc "indicates if an item has any of the specified tags"
  def any_of_tags?(item, tags)

end

defimpl WhiteBread.Tags.Filterer, for: Any do

  def filter(items, tags) do
    items |> Enum.filter(fn (item) -> any_of_tags?(item, tags) end)
  end

  def any_of_tags?(%{tags: element_tags}, tags) do
    overlapping_tags? = tags
      |> tag_overlap(element_tags)
      |> Enum.empty?
    !overlapping_tags?
  end

  defp tag_overlap(tags_one, tags_two) do
    for tag_one <- tags_one,
    tag_two <- tags_two,
    tag_one == tag_two do
      tag_one
    end
  end
end
