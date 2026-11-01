Feature: Admin dashboard and event review
  Admins can review accounts and see events grouped by their status.

  Scenario: Administrator signs in
    Given an admin account exists
    When the admin logs in
    Then the admin dashboard link is visible

  Scenario: Administrator views dashboard summaries and roles
    Given an admin account exists
    And attendee and organizer accounts exist
    When the admin logs in
    And the admin opens the dashboard
    Then the dashboard shows summaries, roles, and user accounts

  Scenario: Administrator views the user list
    Given an admin account exists
    And attendee and organizer accounts exist
    When the admin logs in
    And the admin opens the users page
    Then the user list shows names, roles, and account status

  Scenario: Administrator reviews pending events
    Given an admin account exists
    And a pending event "Awaiting Approval" exists
    When the admin logs in
    And the admin opens the pending events page
    Then the event appears with disabled approve and reject buttons

  Scenario: Administrator sees pending status and review controls on event details
    Given an admin account exists
    And a pending event "Awaiting Approval" exists
    When the admin logs in
    And the admin opens the details for "Awaiting Approval"
    Then the event details show pending status and disabled review buttons

  Scenario: Administrator views published events separately
    Given an admin account exists
    And a published event "Published Concert" exists
    And a pending event "Awaiting Approval" exists
    When the admin logs in
    And the admin opens the published events page
    Then only the published event appears

  Scenario: Administrator views rejected events separately
    Given an admin account exists
    And a rejected event "Rejected Festival" exists
    And a pending event "Awaiting Approval" exists
    When the admin logs in
    And the admin opens the rejected events page
    Then only the rejected event appears

  Scenario: Attendee cannot open the admin dashboard
    Given I am logged in to my attendee account
    When the admin opens the dashboard
    Then an authorization error is shown
