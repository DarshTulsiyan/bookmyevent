Feature: Sold-out ticket availability
  Attendees can book available tiers but cannot book full tiers.

  Background:
    Given an approved concert has General and VIP tickets
    And I am logged in to my attendee account

  Scenario: One tier is sold out
    Given another attendee books all General tickets
    When I open the concert ticket page
    Then General is sold out and VIP remains selectable
    When I book one VIP ticket
    Then my VIP booking is confirmed

  Scenario: All tiers are sold out
    Given another attendee books all General tickets
    And another attendee books all VIP tickets
    When I open the concert ticket page
    Then no concert tickets can be selected or booked