# BookMyEvent User Stories

## Project Overview

* **App Name:** BookMyEvent
* **Team:** Team Earth (Darsh Tulsiyan, Varsha Goalla, Ankita Dan, Tanvi Patel, Bhagavatiraj Yadav, Yash Jugade)
* **Tech Stack:** Ruby on Rails, PostgreSQL

## User Stories

### US-01: User Sign Up, Log In, and Log Out

* **Priority:** 1 | **Points:** 5 | **Sprint:** 1 | **Role:** All Users
* **User Story:** As a user, I want to create an account, log in, and log out securely so that I can access features specific to my role.
* **Acceptance Criteria:**
  * System allows sign up with valid details and role selection (Attendee, Organizer, Admin).
  * System allows login with valid credentials.
  * System grants access to role-appropriate features.
  * System allows secure log out to end session.

### US-02: Organizer Creates an Event

* **Priority:** 2 | **Points:** 5 | **Sprint:** 1 | **Role:** Organizer
* **User Story:** As an organizer, I want to create an event with title, description, venue, date, and capacity so that it can be submitted for approval.
* **Acceptance Criteria:**
  * Organizer enters title, description, venue, date, and total capacity.
  * System assigns a unique Event ID.
  * System sets event status to pending approval.

### US-03: Organizer Defines Ticket Tiers with Capacity

* **Priority:** 3 | **Points:** 5 | **Sprint:** 1 | **Role:** Organizer
* **User Story:** As an organizer, I want to define ticket tiers with separate capacities so that I can offer options without exceeding overall event capacity.
* **Acceptance Criteria:**
  * Organizer sets tier names and individual capacities (e.g., General Admission, VIP).
  * System assigns a unique ID to each tier.
  * System ensures total tier capacities do not exceed total event capacity.

### US-04: Attendee Browses Public Events

* **Priority:** 4 | **Points:** 2 | **Sprint:** 1 | **Role:** Attendee / Visitor
* **User Story:** As an attendee, I want to browse approved public events so that I can view event details and available spots.
* **Acceptance Criteria:**
  * System displays approved public events with title, date, venue, and available spots.
  * User can click an event to view full details.
  * Pending and rejected events are hidden from the public.

### US-05: Attendee Registers and Receives a Ticket ID

* **Priority:** 5 | **Points:** 5 | **Sprint:** 1 | **Role:** Attendee
* **User Story:** As an attendee, I want to register for a ticket tier so that I receive a unique numeric Ticket ID.
* **Acceptance Criteria:**
  * Attendee selects a tier and registers for an available event.
  * System creates registration and assigns unique numeric Ticket ID.
  * System decrements available capacity for the selected tier.
  * Confirmation screen displays the Ticket ID.

### US-06: Organizer Checks In an Attendee by Ticket ID

* **Priority:** 8 | **Points:** 5 | **Sprint:** 2 | **Role:** Organizer
* **User Story:** As an organizer, I want to check in attendees at the door using their Ticket ID or name so that I can verify entry.
* **Acceptance Criteria:**
  * Organizer enters Ticket ID on check-in dashboard.
  * System verifies ticket belongs to the event and marks as checked in with timestamp.
  * System displays check-in confirmation message.

### US-07: Admin Approves or Rejects Events

* **Priority:** 7 | **Points:** 3 | **Sprint:** 1 | **Role:** Admin
* **User Story:** As an admin, I want to approve or reject submitted events so that only valid events are published.
* **Acceptance Criteria:**
  * Admin reviews pending events and sets status to approved or rejected.
  * Approved events become visible on public listing.
  * Rejected events remain hidden.

### US-08: Sold-Out Message When Capacity Is Full

* **Priority:** 6 | **Points:** 2 | **Sprint:** 1 | **Role:** Attendee
* **User Story:** As an attendee, I want to see a clear "Sold Out" message when an event or tier is full so that I cannot register for full events.
* **Acceptance Criteria:**
  * System blocks registration when capacity reaches 0.
  * System displays clear "Sold Out" error message.
  * No ticket or registration record is created.

### US-09: Duplicate Check-In Rejection

* **Priority:** 9 | **Points:** 2 | **Sprint:** 2 | **Role:** Organizer
* **User Story:** As an organizer, I want duplicate check-in attempts to be rejected so that tickets cannot be reused.
* **Acceptance Criteria:**
  * System rejects check-in if ticket was already used.
  * System shows error message stating ticket is already checked in.
  * Original check-in record and timestamp are preserved.

### US-10: Unauthorized Access Redirect

* **Priority:** 10 | **Points:** 2 | **Sprint:** 2 | **Role:** All Users
* **User Story:** As a user, I want restricted pages to block unauthorized access so that my role privileges are protected.
* **Acceptance Criteria:**
  * Unauthenticated or unauthorized user accessing restricted route is redirected to login.
  * System displays explanatory message.
  * User is returned to target page upon logging in with correct credentials.

### US-11: Organizer Dashboard

* **Priority:** 11 | **Points:** 3 | **Sprint:** 2 | **Role:** Organizer
* **User Story:** As an organizer, I want a dashboard of my events so that I can track registrations and manage check-ins.
* **Acceptance Criteria:**
  * Dashboard lists organizer's events with title, date, status, capacity, and attendee count.
  * Organizer can open event details and check-in pages.
  * Organizer cannot view or manage other organizers' events.

### US-12: Admin Dashboard

* **Priority:** 12 | **Points:** 3 | **Sprint:** 2 | **Role:** Admin
* **User Story:** As an admin, I want a dashboard showing system statistics and moderation queues so that I can manage the platform.
* **Acceptance Criteria:**
  * Dashboard displays total users, total events, and total registrations.
  * Admin can approve/reject events and manage user accounts.
  * Non-admins cannot access this page.

### US-13 (Stretch): Waitlist for Sold-Out Events

* **Priority:** 13 | **Points:** 5 | **Sprint:** 2 | **Role:** Attendee
* **User Story:** As an attendee, I want to join a waitlist for sold-out events so that I can get a ticket if someone cancels.
* **Acceptance Criteria:**
  * Attendee joins waitlist when event is full.
  * System maintains ordered waitlist.
  * System auto-promotes waitlisted attendee when spot opens up and generates Ticket ID.

### US-14 (Stretch): Organizer Analytics per Event

* **Priority:** 14 | **Points:** 5 | **Sprint:** 2 | **Role:** Organizer
* **User Story:** As an organizer, I want to view analytics for my events so that I can measure attendance rate.
* **Acceptance Criteria:**
  * Displays total registrations and tier breakdown.
  * Displays checked-in count and check-in percentage ($\text{Check-in Rate} = \frac{\text{Checked-in}}{\text{Registrations}} \times 100\%$).
  * Accessible only by event owner.