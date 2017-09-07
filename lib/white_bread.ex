defmodule WhiteBread do
  alias WhiteBread.Runners.FeatureRunner

  # Features are capped to one hour. In practise the scenario's should be
  # controlling the time out
  @max_feature_run_time 1000 * 60 * 60

  def run(context, path, options \\ []) do
    tags = options |> Keyword.get(:tags)
    async = options |> Keyword.get(:async, false)
    roles = options |> Keyword.get(:roles)

    features = path
      |> WhiteBread.Feature.Finder.find_in_path
      |> read_in_feature_files
      |> parse_features
      |> filter_features(tags: tags, roles: roles)

    results = features
      |> run_all_features(context, async: async)
      |> results_as_map
      |> output_result

    results
  end

  defp results_as_map(results) do
    %{
      successes: results |> Enum.filter(&feature_success?/1),
      failures:  results |> Enum.filter(&feature_failure?/1)
    }
  end

  defp output_result(result_map) do
    WhiteBread.Outputer.report({:final_results, result_map})
    result_map
  end

  defp read_in_feature_files(file_paths) do
    file_paths |> Stream.map(&({&1, File.read!(&1)}))
  end

  defp parse_features(feature_texts) do
    feature_texts
    |> Enum.map(&parse_task/1)
    |> Enum.map(&Task.await/1)
  end

  defp parse_task({file_name, feature_text}) do
    Task.async(fn -> Gherkin.Parser.parse_feature(feature_text, file_name) end)
  end

  defp filter_features(features, tags: tags, roles: roles) do
    features
      |> filter_features_with_roles(roles)
      |> filter_features_with_tags(tags)
  end

  defp filter_features_with_tags(features, nil), do: features
  defp filter_features_with_tags(features, tags) do
      features
        |> WhiteBread.Tags.FeatureFilterer.get_for_tags(tags)
  end

  defp filter_features_with_roles(features, nil), do: features
  defp filter_features_with_roles(features, roles) do
      features
        |> WhiteBread.Roles.FeatureFilterer.get_for_roles(roles)
  end

  defp run_all_features(features, context, async: true) do
    features
      |> Enum.map(&run_feature_async(&1, context))
      |> Enum.map(&Task.await(&1, @max_feature_run_time))
  end

  defp run_all_features(features, context, async: false) do
    features
      |> Enum.map(&run_feature(&1, context))
  end

  defp run_feature(feature, context) do
    {feature, FeatureRunner.run(feature, context, async: false)}
  end

  defp run_feature_async(feature, context) do
    Task.async fn ->
      {feature, FeatureRunner.run(feature, context, async: true)}
    end
  end

  defp feature_success?({_feature, %{failures: failures}}) do
    failures == []
  end

  defp feature_failure?({_feature, %{failures: failures}}) do
    failures != []
  end
end
