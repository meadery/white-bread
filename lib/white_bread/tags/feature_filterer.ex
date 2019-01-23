defmodule WhiteBread.Tags.FeatureFilterer do
  import WhiteBread.Tags.Filterer

  def get_for_tags(features, tags) when is_list(features) do
    features
      |> filter(tags)
      |> Kernel.++(features_with_matching_scenarios(features, tags))
  end

  defp features_with_matching_scenarios(features, tags) do
    features
      |> remove_scenarios_without_tags(tags)
      |> remove_empty_features
  end

  defp remove_scenarios_without_tags(features, tags) do
    features
      |> Enum.map(fn(feature) -> filter_features_scenarios(feature, tags) end)
  end

  defp filter_features_scenarios(feature = %{scenarios: scenarios}, tags) do
    %{feature | scenarios: filter(scenarios, tags)}
  end

  defp remove_empty_features(features) do
    features |> Enum.filter(fn(%{scenarios: scenarios}) -> scenarios != [] end)
  end

end
