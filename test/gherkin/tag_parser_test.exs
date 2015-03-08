defmodule WhiteBread.Gherkin.TagParserTest do
  use ExUnit.Case
  import WhiteBread.Gherkin.Parser
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  @feature_with_single_feature_tag """
  @beverage
  Feature: Serve coffee
  Coffee should not be served until paid for
  Coffee should not be served until the button has been pressed
  If there is no coffee left then money should be refunded

  Scenario: Buy last coffee
  Given there are 1 coffees left in the machine
  """

  @feature_with_many_feature_tags """
  @beverage @coffee @happy
  Feature: Serve coffee
  Coffee should not be served until paid for
  Coffee should not be served until the button has been pressed
  If there is no coffee left then money should be refunded

  Scenario: Buy last coffee
  Given there are 1 coffees left in the machine
  """

  test "Parses the feature with single tag" do
    %{tags: tags} = parse_feature(@feature_with_single_feature_tag)
    assert tags == ["beverage"]
  end

  test "Parses the feature with many tags" do
    %{tags: tags} = parse_feature(@feature_with_many_feature_tags)
    assert tags == ["beverage", "coffee", "happy"]
  end

end
