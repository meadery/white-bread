Feature: Doc Strings for steps are also a thing
  Any step should be able to have a doc string

  Background:
    Given the following doc string:
    """
    This should
      Work!
    """

    Scenario: Doc string with step
      Given the following doc string:
      """
      This should
        Work!
      """
      Then the doc string should be okay.

    Scenario: Background doc string
      Then the doc string should be okay.
