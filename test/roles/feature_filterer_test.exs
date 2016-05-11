defmodule WhiteBread.Roles.FeatureFiltererTest do
  use ExUnit.Case
  alias WhiteBread.Gherkin.Elements.Feature
  alias WhiteBread.Roles.FeatureFilterer


  test "Returns a feature if it has a matching role" do
    feature = %Feature{role: "developer"}
    other_feature = %Feature{}
    features = [feature, other_feature]

    assert FeatureFilterer.get_for_roles(features, ["developer"]) == [feature]
  end


end
