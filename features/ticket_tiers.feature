Feature: Ticket tier capacity management
  Organizers can configure ticket tiers within an event's total capacity.

  Scenario: Add ticket tiers within event capacity
    Given an organizer owns an event with a capacity of 100
    When the organizer adds a "General" tier with capacity 60
    And the organizer adds a "VIP" tier with capacity 40
    Then the event should have 2 ticket tiers
    And the event should have 0 remaining unallocated seats

  Scenario: Reject a ticket tier that exceeds event capacity
    Given an organizer owns an event with a capacity of 100
    And the event already has a "General" tier with capacity 60
    When the organizer adds a "VIP" tier with capacity 41
    Then the ticket tier should not be saved
    And a capacity validation error should be shown

  Scenario: Update an existing ticket tier
    Given an organizer owns an event with a capacity of 100
    And the event already has a "General" tier with capacity 40
    When the organizer updates the "General" tier to capacity 60
    Then the "General" tier should have capacity 60

  Scenario: Reject an update that exceeds event capacity
    Given an organizer owns an event with a capacity of 100
    And the event already has a "General" tier with capacity 60
    When the organizer updates the "General" tier to capacity 101
    Then the "General" tier should still have capacity 60
    And a capacity validation error should be shown

  Scenario: Delete a ticket tier without sold tickets
    Given an organizer owns an event with a capacity of 100
    And the event already has a "General" tier with capacity 40
    When the organizer deletes the "General" tier
    Then the event should have 0 ticket tiers

  Scenario: Prevent deletion of a ticket tier with sold tickets
    Given an organizer owns an event with a capacity of 100
    And the event already has a "General" tier with capacity 40
    And the "General" tier has a sold ticket
    When the organizer deletes the "General" tier
    Then the "General" tier should still exist
    And a sold-ticket deletion error should be shown
