# BookMyEvent -- Pair Programming

## Introduction

Pair programming is an Agile software development practice in which two
team members work together at one workstation. One person acts as the
**Driver**, writing the code, while the other acts as the **Navigator**,
reviewing the work, thinking ahead, and suggesting improvements. The
teammates switch roles periodically.

This log outlines proposed pair programming sessions for the six members
of the BookMyEvent team. Each session identifies the driver, navigator,
work area, activities, and outcome.


## Pair Programming Sessions

### Session 1 -- User Authentication and Initial Setup

-   **Driver:** Darsh
-   **Navigator:** Tanvi
-   **Work area:** US-01 -- Initial project setup and user
    authentication

**Activities**

Configured the initial Rails application structure. Worked on user signup, login, and logout functionality. Reviewed the authentication flow and shared access-control helpers. Discussed edge cases and reviewed the implementation together.

**Outcome**

Established the application's initial structure and authentication workflow. Identified issues and improvements through collaborative review.

### Session 2 -- Event Creation

-   **Driver:** Tanvi
-   **Navigator:** Yash
-   **Work area:** US-02 -- Event creation and management

**Activities**

Discussed the event creation workflow for organizers. Reviewed event fields and form validations. Worked through the interaction between event forms, controllers, and models. Checked that invalid input was handled appropriately.

**Outcome**

Improved the event creation workflow and clarified how the event-related components interacted.

### Session 3 -- Ticket Tier Management and Capacity Validation

-   **Driver:** Ankita
-   **Navigator:** Darsh
-   **Work area:** US-03 -- Ticket tiers and capacity validation

**Activities**

Implemented ticket tier creation, updating, and deletion. Added validations for tier names and positive capacities. Ensured that the combined capacity of all ticket tiers did not exceed the event's total capacity. Prevented capacity reductions below the number of tickets already sold. Reviewed the remaining-seat calculations and organizer-only access.

**Outcome**

Developed ticket tier management functionality with capacity safeguards and collaborative code review.

### Session 4 -- Event Browsing

-   **Driver:** Yash
-   **Navigator:** Varsha
-   **Work area:** US-04 -- Event browsing

**Activities**

Discussed how attendees could browse available events. Reviewed event listing and display requirements. Considered how event status and availability should affect what attendees saw. Reviewed the user experience and possible edge cases.

**Outcome**

Clarified the event discovery workflow and identified improvements to event browsing.

### Session 5 -- Ticket Booking

-   **Driver:** Varsha
-   **Navigator:** Bhagavati
-   **Work area:** US-05 -- Ticket booking

**Activities**

Discussed the attendee ticket booking workflow. Reviewed how ticket availability and tier capacity should be checked. Considered how the application should respond when a tier was sold out. Reviewed booking validation and possible concurrent booking scenarios.

**Outcome**

Refined the booking workflow and identified safeguards needed to avoid exceeding ticket capacity.

### Session 6 -- Event Approval and Sold-Out Handling

-   **Driver:** Bhagavati
-   **Navigator:** Ankita
-   **Work area:** Event approval and sold-out handling

**Activities**

Discussed the event approval workflow and the roles involved. Reviewed how event status should change during approval or rejection. Considered how sold-out ticket tiers and events should be represented. Reviewed edge cases and the interaction between approval and ticket availability.

**Outcome**

Clarified the approval and sold-out workflows and identified areas requiring validation and testing.

## Reflection

Pair programming encourages continuous feedback, shared understanding,
and early identification of defects. Rotating the Driver and Navigator
roles gives both teammates opportunities to contribute directly to
implementation and review.

For BookMyEvent, pairing across different user stories can also help
team members understand how features connect---for example, how event
capacity affects ticket tiers and how ticket availability affects the
booking process.