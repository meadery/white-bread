defmodule WhiteBread.Suite.ContextPerFeatureTest do
  use ExUnit.Case
  alias WhiteBread.Suite

  alias WhiteBread.Suite.ContextPerFeature

  test "Build a list of suites" do
    actual = ContextPerFeature.build_suites(%{
        namespace_prefix: WhiteBread,
        entry_feature_path: "features/"
      })

    assert Enum.member?(actual, %Suite{
            name: "Example1",
            context: WhiteBread.Example1Context,
            feature_paths: ["features/example1.feature"]
          })
  end

  test "Build a suite struct" do
    actual = ContextPerFeature.build_suite(%{
        namespace_prefix: WhiteBread,
        entry_feature_path: "features/"
      }, "features/something_special.feature")

    assert actual == %Suite{
            name: "SomethingSpecial",
            context: WhiteBread.SomethingSpecialContext,
            feature_paths: ["features/something_special.feature"]
          }
  end

end
