defmodule WhiteBread.SuiteConfigurationTest do
  use ExUnit.Case
  alias WhiteBread.Suite
  alias WhiteBread.Suite.DuplicateSuiteError

  alias WhiteBread.SuiteConfigurationTest.SingleSuite
  alias WhiteBread.SuiteConfigurationTest.DoubleSuite
  alias WhiteBread.SuiteConfigurationTest.DuplicateSuiteNames
  alias WhiteBread.SuiteConfigurationTest.DoubleDuplicateSuiteNames


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
    assert_raise DuplicateSuiteError, "Duplicate suite names found: Core Domain", fn ->
      DuplicateSuiteNames.suites
    end
  end

  test "suite names not being unique lists all the problems in the error" do
    assert_raise DuplicateSuiteError, "Duplicate suite names found: Another Domain, Core Domain", fn ->
      DoubleDuplicateSuiteNames.suites
    end
  end

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

defmodule WhiteBread.SuiteConfigurationTest.DoubleDuplicateSuiteNames do
  use WhiteBread.SuiteConfiguration

  suite name:          "Core Domain",
        context:       ExampleContext,
        feature_paths: ["features/core"]

  suite name:          "Core Domain",
        context:       ApiContext,
        feature_paths: ["features/api"]

  suite name:          "Another Domain",
        context:       ExampleContext,
        feature_paths: ["features/core"]

  suite name:          "Another Domain",
        context:       ApiContext,
        feature_paths: ["features/api"]
end
