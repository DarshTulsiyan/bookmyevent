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

  Scenario: Visitor browses approved events and sees available seats
    Given an approved public event "Public Concert" exists
    And the public event has a "General" tier with capacity 20 and 8 sold
    And a pending event "Pending Concert" exists
    When I visit the public events page
    Then the public event shows its title, date, venue, and seats left
    And the pending event is not listed

  Scenario: Attendee cannot create events
    Given I am logged in to my attendee account
    When I visit the new event page
    Then the event page should show "Not authorized"
