defmodule WhiteBread.Gherkin.ParserTest do
  use ExUnit.Case
  import WhiteBread.Gherkin.Parser
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

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

  @feature_with_backgroundtext """
  Feature: Serve coffee
    Coffee should not be served until paid for
    Coffee should not be served until the button has been pressed
    If there is no coffee left then money should be refunded

    Background:
      Given coffee exists as a beverage
      And there is a coffee machine

    Scenario: Buy last coffee
      Given there are 1 coffees left in the machine
      And I have deposited 1$
      When I press the coffee button
      Then I should be served a coffee
  """

  @feature_with_single_feature_tag """
  @beverage
  Feature: Serve coffee
    Coffee should not be served until paid for
    Coffee should not be served until the button has been pressed
    If there is no coffee left then money should be refunded

  Scenario: Buy last coffee
    Given there are 1 coffees left in the machine
  """

  @feature_with_step_with_table """
  Feature: Have tables
    Sometimes data is a table

    Scenario: I have a step with a table
      Given the following table
      | Column one | Column two |
      | Hello      | World      |
      Then everything should be okay
  """

  @feature_with_doc_string "
  Feature: Have tables
    Sometimes data is a table

    Scenario: I have a step with a doc string
      Given the following data
      \"\"\"json
      {
        \"a\": \"b\"
      }
      \"\"\"
      Then everything should be okay
  "

  @feature_with_scenario_outline """
  Feature: Scenario outlines exist

    Scenario Outline: eating
      Given there are <start> cucumbers
      When I eat <eat> cucumbers
      Then I should have <left> cucumbers

    Examples:
      | start | eat | left |
      |  12   |  5  |  7   |
      |  20   |  5  |  15  |
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

  test "Gets the scenario's name" do
    %{scenarios: [%{name: name} | _]} = parse_feature(@feature_text)
    assert name == "Buy last coffee"
  end

  test "Gets the correct number of steps for the scenario" do
    %{scenarios: [%{steps: steps} | _]} = parse_feature(@feature_text)
    assert Enum.count(steps) == 4
  end

  test "Has the correct steps for a scenario" do
    expected_steps = [
      %Steps.Given{text: "there are 1 coffees left in the machine"},
      %Steps.And{text: "I have deposited 1$"},
      %Steps.When{text: "I press the coffee button"},
      %Steps.Then{text: "I should be served a coffee"},
    ]
    %{scenarios: [%{steps: steps} | _]} = parse_feature(@feature_text)
    assert expected_steps == steps
  end

  test "Parses the expected background steps" do
    expected_steps = [
      %Steps.Given{text: "coffee exists as a beverage"},
      %Steps.And{text: "there is a coffee machine"}
    ]
    %{background_steps: background_steps} = parse_feature(@feature_with_backgroundtext)
    assert expected_steps == background_steps
  end

  test "Reads a doc string in to the correct step" do
    expected_data = "{\n  \"a\": \"b\"\n}\n"
    expected_steps = [
      %Steps.Given{text: "the following data", doc_string: expected_data},
      %Steps.Then{text: "everything should be okay"},
    ]
    %{scenarios: [%{steps: steps} | _]} = parse_feature(@feature_with_doc_string)
    assert expected_steps == steps
  end

  test "Reads a table in to the correct step" do
    exptected_table_data = [
      ["Column one", "Column two"],
      ["Hello", "World"]
    ]
    expected_steps = [
      %Steps.Given{text: "the following table", table_data: exptected_table_data},
      %Steps.Then{text: "everything should be okay"},
    ]
    %{scenarios: [%{steps: steps} | _]} = parse_feature(@feature_with_step_with_table)
    assert expected_steps == steps
  end

  test "Reads Scenario outlines correctly" do
    exptected_example_data = [
      ["start", "eat", "left"],
      ["12",    "5",   "7"   ],
      ["20",    "5",   "15"  ]
    ]
    expected_steps = [
      %Steps.Given{text: "there are <start> cucumbers"},
      %Steps.When{text: "I eat <eat> cucumbers"},
      %Steps.Then{text: "I should have <left> cucumbers"}
    ]
    %{scenarios: [%{steps: steps, examples: examples} | _]} = parse_feature(@feature_with_scenario_outline)
    assert steps == expected_steps
    assert examples == exptected_example_data
  end

end
