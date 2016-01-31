defmodule WhiteBread.ContextPerFeature do
  defstruct on: false,
            namespace_prefix: WhiteBread.Context,
            entry_feature_path: "features/"
end