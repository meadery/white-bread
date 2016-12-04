Feature: Tables for steps are a thing
    Any step should be able to have a table of data.

    Scenario: Table with step
      Given the following table:
      | Person | First animal | Second Animal |
      | Odin   | Huginn       | Muninn        |
      | Thor   | Tanngrisnir  | Tanngnjóstr   |
      Then everything should be okay.

    Scenario Outline: These can run two
      Given I am <Person>
      Then I should have <Pets>

    Examples:
      | Person | Pets                        |
      | Odin   | Huginn and Muninn           |
      | Thor   | Tanngrisnir and Tanngnjóstr |
