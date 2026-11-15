Feature: Authorization documents for event review
  An organizer submits proof before an admin publishes the event.

  Scenario: An organizer replaces rejected proof and the published document stays private
    Given an admin account exists
    And a draft event "Campus Concert" exists
    When the event owner logs in and opens the event editor
    And the organizer submits the document "venue-permit.pdf"
    Then the event page should show "Pending Review"
    When I log out of my account
    And the admin logs in
    And the admin opens the pending events page
    And the admin opens the details for "Campus Concert"
    Then the authorization document downloads as "venue-permit.pdf"
    When the admin rejects the event with reason "Please provide the updated permit"
    And I log out of my account
    And the event owner logs in and opens the event editor
    Then the event page should show "Please provide the updated permit"
    When the organizer submits the document "updated-permit.pdf"
    Then the event page should show "Pending Review"
    When I log out of my account
    And the admin logs in
    And the admin opens the pending events page
    And the admin opens the details for "Campus Concert"
    Then the authorization document downloads as "updated-permit.pdf"
    When the admin opens the details for "Campus Concert"
    And the admin publishes the event
    And I log out of my account
    And I open the public events listing
    Then the public listing should include "Campus Concert"
    And the authorization document URL returns 404
