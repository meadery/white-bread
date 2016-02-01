defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

  context_per_feature on: true,
                      namespace_prefix: WhiteBread.TestContextPerFeature,
                      entry_feature_path: "features/test_context_per_feature/"

  suite name:          "Default",
        context:       WhiteBread.Example.DefaultContext,
        feature_paths: ["features/"]

  suite name:          "Alternate",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/"]

  suite name:          "Alternate - Songs",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/"],
        tags:          ["songs"]
end
