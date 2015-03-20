Feature: Tables for steps are a thing
    Any step should be able to have a table of data.

    Scenario: Table with step
        Given the following table:
        | Odin | Huginn      | Muninn      |
        | Thor | Tanngrisnir | Tanngnjóstr |
        Then everything should be okay.
