defmodule WhiteBread.Tags.Filterer do

  def filter(items, tags) when is_list(tags) do
    items |> Enum.filter(get_filter_for_tags(tags))
  end

  defp get_filter_for_tags(tags) do
    fn (%{tags: element_tags}) -> !(tag_overlap(tags, element_tags) |> Enum.empty?) end
  end

  defp tag_overlap(tags_one, tags_two) do
    for tag_one <- tags_one,
        tag_two <- tags_two,
        tag_one == tag_two do
       tag_one
    end
  end


end
