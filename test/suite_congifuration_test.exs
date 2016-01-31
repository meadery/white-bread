defmodule WhiteBread.SuiteConfigurationTest do
  use ExUnit.Case
  alias WhiteBread.Suite
  alias WhiteBread.ContextPerFeature
  alias WhiteBread.Suite.DuplicateSuiteError

  alias WhiteBread.SuiteConfigurationTest.ContextPerFeatureConfig
  alias WhiteBread.SuiteConfigurationTest.SingleSuite
  alias WhiteBread.SuiteConfigurationTest.DoubleSuite
  alias WhiteBread.SuiteConfigurationTest.DuplicateSuiteNames

  test "load in context per feature file set to true" do
    assert ContextPerFeatureConfig.context_per_feature == %ContextPerFeature{ 
      entry_feature_path: "features/context_per_feature",
      on: true,
      namespace_prefix: WhiteBread.Example 
    }
  end

  test "define a single suite" do
    assert Enum.count(SingleSuite.suites) == 1
    assert Enum.member?(
      SingleSuite.suites,
      %Suite{name: "Core Domain",
            context: ExampleContext,
            feature_paths: ["features/core"],
            tags: ["good"]
      }
    )
    assert SingleSuite.context_per_feature == %ContextPerFeature{
      entry_feature_path: "features/",
      on: false,
      namespace_prefix: WhiteBread.Context
    }
  end

  test "defining multiple suites" do
    assert Enum.count(DoubleSuite.suites) == 2
    assert Enum.member?(
      DoubleSuite.suites,
      %Suite{name: "Core Domain",
             context: ExampleContext,
             feature_paths: ["features/core"]
      }
    )
    assert Enum.member?(
      DoubleSuite.suites,
      %Suite{name: "Api",
             context: ApiContext,
             feature_paths: ["features/api"]
      }
    )
  end

  test "suite names are unique" do
    assert_raise DuplicateSuiteError, "All suites must have unique names", fn ->
      DuplicateSuiteNames.suites
    end
  end

end

defmodule WhiteBread.SuiteConfigurationTest.ContextPerFeatureConfig do
  use WhiteBread.SuiteConfiguration

  context_per_feature on: true,
                      namespace_prefix: WhiteBread.Example,
                      entry_feature_path: "features/context_per_feature"

end

defmodule WhiteBread.SuiteConfigurationTest.SingleSuite do
  use WhiteBread.SuiteConfiguration

  suite name:          "Core Domain",
        context:       ExampleContext,
        feature_paths: ["features/core"],
        tags:          ["good"]
end

defmodule WhiteBread.SuiteConfigurationTest.DoubleSuite do
  use WhiteBread.SuiteConfiguration

  suite name:          "Core Domain",
        context:       ExampleContext,
        feature_paths: ["features/core"]

  suite name:          "Api",
        context:       ApiContext,
        feature_paths: ["features/api"]
end

defmodule WhiteBread.SuiteConfigurationTest.DuplicateSuiteNames do
  use WhiteBread.SuiteConfiguration

  suite name:          "Core Domain",
        context:       ExampleContext,
        feature_paths: ["features/core"]

  suite name:          "Core Domain",
        context:       ApiContext,
        feature_paths: ["features/api"]
end
