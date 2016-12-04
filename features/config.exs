defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

  context_per_feature namespace_prefix: WhiteBread.TestContextPerFeature,
                      entry_path: "features/test_context_per_feature/",
                      extra: [
                        run_async: true
                      ]

  suite name:          "Default context",
        context:       WhiteBread.Example.DefaultContext,
        feature_paths: ["features/default/"],
        run_async:     true

  suite name:          "Alternate context",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/default/"]

  suite name:          "Plain context - Songs",
        context:       WhiteBread.Example.PlainContext,
        feature_paths: ["features/default/"],
        tags:          ["songs"]

  suite name:          "Singer role",
        context:       WhiteBread.Example.PlainContext,
        feature_paths: ["features/default/"],
        roles:         ["singer"]

  suite name:          "Outline context",
        context:       WhiteBread.Example.OutlineContext,
        feature_paths: ["features/outline/"],
        tags:          ["outline"]

end
