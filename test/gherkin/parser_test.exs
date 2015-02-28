defmodule WhiteBread.Gherkin.ParserTest do
  use ExUnit.Case
  import WhiteBread.Gherkin.Parser

  @feature_text """
    Feature: Serve coffee
      Coffee should not be served until paid for
      Coffee should not be served until the button has been pressed
      If there is no coffee left then money should be refunded

      Scenario: Buy last coffee
        Given there are 1 coffees left in the machine
        And I have deposited 1$
        When I press the coffee button
        Then I should be served a coffee

      Scenario: Be sad that no coffee is left
        Given there are 0 coffees left in the machine
        And I have deposited 1$
        When I press the coffee button
        Then I should be frustrated
  """

  test "Parses the feature name" do
    %{name: name} = parse_feature(@feature_text)
    assert name == "Serve coffee"
  end

  test "Parses the feature description" do
    %{description: description} = parse_feature(@feature_text)
    assert description == """
    Coffee should not be served until paid for
    Coffee should not be served until the button has been pressed
    If there is no coffee left then money should be refunded
    """
  end

  test "reads in the correct number of scenarios" do
    %{scenarios: scenarios} = parse_feature(@feature_text)
    assert Enum.count(scenarios) == 2
  end

  test "Gets the scenarios name" do
    %{scenarios: [%{name: name} | _]} = parse_feature(@feature_text)
    assert name == "Buy last coffee"
  end

end
