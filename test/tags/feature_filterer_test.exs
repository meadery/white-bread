defmodule WhiteBread.Tags.FeatureFiltererTest do
  use ExUnit.Case
  import WhiteBread.Tags.FeatureFilterer, only: [get_for_tags: 2]
  alias WhiteBread.Gherkin.Elements.Feature, as: Feature
  alias WhiteBread.Gherkin.Elements.Scenario, as: Scenario

  test "Returns a feature if it has a matching tag" do
    feature = %Feature{tags: ["matching"]}
    assert get_for_tags([feature], ["matching"]) == [feature]
  end

  test "Returns a feature with filtered scenarios if any of them match" do
    matching_scenario = %Scenario{tags: ["matching"]}
    other_scenario = %Scenario{}
    feature = %Feature{name: "mine", scenarios: [matching_scenario, other_scenario]}
    assert get_for_tags([feature], ["matching"]) == [%{feature | scenarios: [matching_scenario]}]
  end

end
