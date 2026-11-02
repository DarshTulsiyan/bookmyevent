Feature: Attendee books tickets
  Attendees can book multiple seats across tiers and see individual Ticket IDs.

  Scenario: Book multiple tiers and view tickets
    Given an approved concert has General and VIP tickets
    And I am logged in to my attendee account
    When I book 2 General tickets and 1 VIP ticket
    Then I should see my three tickets grouped under one booking
    And the concert should have sold 2 General tickets and 1 VIP ticket

  Scenario: Capacity changes before the booking is submitted
    Given an approved concert has General and VIP tickets
    And I am logged in to my attendee account
    And I am choosing concert tickets
    And another attendee books all General tickets
    When I submit my concert ticket selection
    Then I should see a sold-out booking error
    And I should have no bookings
