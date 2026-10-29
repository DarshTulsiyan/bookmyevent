Feature: Event creation
  Organizers can create events, which wait for admin approval.

  Scenario: Organizer creates an event
    Given I am logged in as an organizer
    When I create an event with valid details
    Then the event page should show "Pending approval"
    And the event page should show "Ticket tiers"

  Scenario: Missing event title
    Given I am logged in as an organizer
    When I create an event without a title
    Then the event page should show "Title can't be blank"

  Scenario: Attendee views an approved event
    Given an approved event "Spring Concert" exists
    And I am logged in to my attendee account
    When I browse events and open "Spring Concert"
    Then the event page should show "Rudder Auditorium"

  Scenario: Attendee cannot create events
    Given I am logged in to my attendee account
    When I visit the new event page
    Then the event page should show "Not authorized"
