Feature: Event approval decisions
  Admins decide whether pending events become public.
  Organizers can see the resulting status.

  Background:
    Given an admin account exists
    And a pending event "Community Concert" exists

  Scenario Outline: Admin decides on an event
    When the admin logs in
    And the admin opens the pending events page
    And the admin chooses "<button>" for "Community Concert"
    Then the event page should show "<message>"
    And "Community Concert" is absent from the pending events table
    When I log out of my account
    And I open the public events listing
    Then the public listing should <visibility> "Community Concert"
    When the event owner logs in and opens the event editor
    Then the event page should show "<status>"

    Examples:
      | button            | message                       | visibility  | status   |
      | Approve & publish | Event approved and published. | include     | Approved |
      | Reject            | Event rejected.               | not include | Rejected |