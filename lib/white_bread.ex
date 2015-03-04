defmodule WhiteBread do
  def run(context) do
    output = WhiteBread.Outputers.Console.start

    results = WhiteBread.Feature.Finder.find_in_path("features/")
    |> read_in_feature_files
    |> parse_features
    |> run_all_features(context, output)

    output |> WhiteBread.Outputers.Console.stop

    %{
      successes: results |> Enum.filter(&feature_success?/1),
      failures:  results |> Enum.filter(&feature_failure?/1)
    }
  end

  defp read_in_feature_files(file_paths) do
    file_paths |> Stream.map(&File.read!/1)
  end

  defp parse_features(feature_texts) do
    feature_texts |> Stream.map(&WhiteBread.Gherkin.Parser.parse_feature/1)
  end

  defp run_all_features(features, context, output) do
    features |> Enum.map(get_feature_runner(context, output))
  end

  defp get_feature_runner(context, output) do
    fn(feature) -> {feature, WhiteBread.FeatureRunner.run(feature, context, output)} end
  end

  defp feature_success?({_feature, %{failures: failures}}) do
    failures == []
  end

  defp feature_failure?({_feature, %{failures: failures}}) do
    failures != []
  end

end
