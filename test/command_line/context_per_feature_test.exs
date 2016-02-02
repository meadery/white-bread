defmodule WhiteBread.CommandLine.ContextPerFeatureTest do
  use ExUnit.Case
  alias WhiteBread.CommandLine
  alias WhiteBread.ContextPerFeature
  alias WhiteBread.Suite

  test "Build a list of suites" do
    {status, actual} = CommandLine.ContextPerFeature.build_suites(%ContextPerFeature{
        on: true,
        namespace_prefix: WhiteBread,
        entry_feature_path: "features/"
      })

    assert status == :ok
    assert Enum.member?(actual, %Suite{
            name: "Example1",
            context: WhiteBread.Example1Context,
            feature_paths: ["features/example1.feature"]
          })
  end

  test "Context per feature is turned off" do
    {status, _message} = CommandLine.ContextPerFeature.build_suites(%ContextPerFeature{
        on: false,
        namespace_prefix: WhiteBread,
        entry_feature_path: "features/"
      })

    assert status == :error
  end

  test "Build a suite struct" do
    actual = CommandLine.ContextPerFeature.build_suite(%ContextPerFeature{ 
        on: true,
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