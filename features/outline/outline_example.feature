@outline
Feature: Scenario outlines
  As a user
  I can write scenario outlines
  So I can try a scenario with several sets of data

  Scenario Outline: Basic outline
    Given the string "one and two"
    Then the string should contain "<substring>"

    Examples:
      | substring |
      | one       |
      | two       |

  Scenario Outline: Load starting state
    Given a scenario outline
    Then it should load the scenario starting state

    Examples:
      | dummy |
      | null  |

  Scenario Outline: Reload starting state for each example row
    Given some additional state "<state>"
    Then it should have only the additional state "<state>"

    Examples:
      | state |
      | foo   |
      | bar   |

  Scenario Outline: Interpolate placeholders in tables
    Given I have the following table:
      | data          |
      | <placeholder> |
    Then the table data should contain "<placeholder>"
    But the table data should not contain "placeholder"

    Examples:
      | placeholder |
      | real value  |
