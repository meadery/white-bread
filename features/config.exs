defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

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
