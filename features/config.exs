defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

  context_per_feature namespace_prefix: WhiteBread.TestContextPerFeature,
                      entry_path: "features/test_context_per_feature/"

  suite name:          "Default context",
        context:       WhiteBread.Example.DefaultContext,
        feature_paths: ["features/"]

  suite name:          "Alternate context",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/"]

  suite name:          "Plain context - Songs",
        context:       WhiteBread.Example.PlainContext,
        feature_paths: ["features/"],
        tags:          ["songs"]
end
