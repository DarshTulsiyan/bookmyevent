Feature: Sudo account role workspaces
  A development superuser can open attendee, organizer, and admin workspaces.

  Scenario: Sudo account opens all role workspaces
    Given a sudo account exists
    When the sudo account logs in
    Then the sudo account can open attendee, organizer, and admin workspaces

  Scenario: Attendee cannot open the admin workspace
    Given I am logged in to my attendee account
    When the admin opens the dashboard
    Then an authorization error is shown
