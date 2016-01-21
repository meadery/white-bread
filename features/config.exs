defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

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
