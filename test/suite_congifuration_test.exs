defmodule WhiteBread.SuiteConfigurationTest do
  use ExUnit.Case
  alias WhiteBread.Suite

  alias WhiteBread.SuiteConfigurationTest.SingleSuite
  alias WhiteBread.SuiteConfigurationTest.DoubleSuite

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

end

defmodule WhiteBread.SuiteConfigurationTest.SingleSuite do
  use WhiteBread.SuiteConfiguration

  suite name:    "Core Domain",
        context: ExampleContext,
        feature_paths: ["features/core"],
        tags: ["good"]
end

defmodule WhiteBread.SuiteConfigurationTest.DoubleSuite do
  use WhiteBread.SuiteConfiguration

  suite name:    "Core Domain",
        context: ExampleContext,
        feature_paths: ["features/core"]

  suite name:    "Api",
        context: ApiContext,
        feature_paths: ["features/api"]
end
