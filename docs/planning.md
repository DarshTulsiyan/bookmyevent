# BookMyEvent Planning Discussion

Date: 2026-11-02  
Project team: Team Earth

This document records the overall project plan for BookMyEvent.

## What We Will Build

We will build BookMyEvent, a web application for discovering events and booking tickets. Visitors can browse approved upcoming events. Attendees can book tickets and manage their tickets. Organizers can create events, manage event information and ticket tiers, and support entry check-in. Admins can review submitted events and oversee platform activity.

The application will use Ruby on Rails, PostgreSQL, and server-rendered HTML. RSpec will cover unit and request behavior; Cucumber will express acceptance scenarios.

## Essential and Optional Features

### Essential scope

- Create attendee and organizer accounts; securely log in and log out.
- Enforce role-appropriate access; do not allow public signup to create admin accounts.
- Create an event with a unique ID, title, description, venue, start date/time, capacity, and pending approval status.
- View and update events according to the signed-in user's role and event ownership.
- Let organizers view only their events, their approval statuses, capacities, and applicable ticket statistics.
- Let organizers create and manage ticket tiers while ensuring their combined capacities do not exceed event capacity.
- Let admins review pending events and approve or reject them.
- Keep pending, approved/published, and rejected events distinguishable in admin views.
- Show only approved future events in the public listing, soonest first; hide pending, rejected, and past events.
- Show public event details, ticket tiers, and seats remaining.
- Let attendees book one or more tickets across tiers in a single booking.
- Give each booking a unique booking ID and each seat a unique ticket ID.
- Enforce capacity atomically: reject insufficient or sold-out requests without partial bookings or overselling.
- Show attendee bookings and ticket IDs in My Tickets.
- Provide organizers with event check-in and reject invalid or duplicate check-ins.
- Protect private routes and records with server-side role and ownership authorization.

### Optional / stretch scope

- Maintain an ordered waitlist for sold-out events and promote attendees when seats become available.
- Provide organizer analytics, including registrations by tier and check-in rate.
- Let organizers submit venue booking proof for admin review, with file type, size, and access controls.
- Add other account-management actions or advanced reporting after the essential stories are complete and requirements are agreed.

## Product Backlog and Estimates

Priorities use lower numbers for higher priority. Points are relative estimates.

| Story | Summary | Priority | Points | Sprint | Role |
|---|---|---:|---:|---:|---|
| US-01 | Sign up, log in, and log out | 1 | 5 | 1 | All users |
| US-02 | Create an event | 2 | 5 | 1 | Organizer |
| US-03 | Define ticket tiers with capacity | 3 | 5 | 1 | Organizer |
| US-04 | Browse approved public events | 4 | 2 | 1 | Attendee / Visitor |
| US-05 | Book tickets and receive booking/ticket IDs | 5 | 5 | 1 | Attendee |
| US-08 | See sold-out status and prevent full-tier bookings | 6 | 2 | 1 | Attendee |
| US-07 | Approve or reject submitted events | 7 | 3 | 1 | Admin |
| US-06 | Check in attendees by ticket ID or name | 8 | 5 | 2 | Organizer |
| US-09 | Reject duplicate check-in | 9 | 2 | 2 | Organizer |
| US-10 | Block unauthorized access | 10 | 2 | 2 | All users |
| US-11 | View organizer dashboard and event activity | 11 | 3 | 2 | Organizer |
| US-12 | View admin dashboard and moderation queues | 12 | 3 | 2 | Admin |
| US-13 | Join a waitlist for sold-out events (stretch) | 13 | 5 | 2 | Attendee |
| US-14 | View per-event organizer analytics (stretch) | 14 | 5 | 2 | Organizer |
| US-15 | Upload venue booking proof (stretch) | 15 | 3 | 2 | Organizer / Admin |

## Delivery Plan

### Sprint 1 — Core event marketplace

Build the account and role foundation first. Add organizer event creation and ticket tiers, then event approval and public browsing. Complete attendee booking and sold-out handling with capacity protections.

Planned stories: US-01, US-02, US-03, US-04, US-05, US-07, and US-08.  
Planned estimate: **27 points**.

### Sprint 2 — Event operations and extensions

Add organizer check-in, duplicate-use prevention, and role/ownership access protections. Provide organizer and admin dashboards. If essential scope is complete and capacity permits, implement the waitlist, analytics, and venue-proof stretch stories.

Planned stories: US-06, US-09, US-10, US-11, and US-12.  
Stretch stories: US-13, US-14, and US-15.  
Planned estimate: **15 essential points**, plus **13 stretch points**.

## Collaboration Plan

- Team members will agree on story scope and acceptance criteria before implementation begins.
- For substantial behavior changes, use pair programming or a peer review so implementation and tests are reviewed together.
- Share driver and reviewer responsibilities across stories so the team understands the application as a whole.
- Implement and review work in small, focused branches; integrate completed stories through pull requests.
- Run the relevant tests during development and the full required checks before a story is considered done.
- Communicate design changes, blockers, and decisions to the team and keep project documentation aligned with the implemented behavior.

## Definition of Done

### Project done

The project is done when:

- Essential backlog stories meet their acceptance criteria.
- Users can complete the core event creation, review, discovery, and booking workflows without unexpected errors.
- Role and ownership restrictions protect private and administrative operations.
- Booking and check-in rules prevent overselling and duplicate ticket use.
- Acceptance tests include happy and sad paths for the implemented backlog items.
- All tests pass.
- Cucumber acceptance-test code coverage is at least 90%.
- RSpec unit-test code coverage is at least 90%.
- Combined test-suite code coverage is at least 90%.
- RuboCop reports zero offenses in models, controllers, helpers, and test code.
- The application is deployed to the production environment and its core workflows are verified there.
- README and project documentation explain setup, execution, testing, and delivered behavior.

### Feature or user story done

An individual story is done when:

- Its acceptance criteria are implemented.
- Cucumber scenarios cover the relevant happy and sad paths and are clear, concise, independent, and executable.
- RSpec examples cover relevant model, request, and boundary behavior.
- All applicable tests pass for the story and the existing suite remains passing.
- Cucumber, RSpec, and combined coverage remain at or above 90%.
- RuboCop reports zero offenses in the required code areas.
- Access control, failure behavior, and validation are tested where relevant.
- The change has been reviewed and is deployed to production as part of the increment.
- User-facing behavior and setup documentation are updated where required.

## Initial Decisions and Risks

- New events begin as pending; only authorized admins can approve or reject them. Public pages show approved future events only.
- Public registration creates attendee or organizer accounts, never admins. Production admin provisioning must be private and must not use shared development credentials.
- Keep ticket booking transactional. Lock and re-check affected tier capacity during booking; if any requested tier is unavailable, reject the entire booking.
- Keep organizer event queries and mutations scoped to the signed-in organizer. Enforce ownership in controller/model behavior, not only in navigation or views.
- Keep tickets as individual seats linked to a booking, so attendees can receive one ticket ID per seat while retaining a single booking ID.
- A failed booking, validation, or unauthorized request must not leave partial database changes.
- Risks include concurrent booking requests, invalid or malicious uploads, duplicate check-ins, role escalation, and production configuration mistakes. Address these with database constraints, server-side authorization, boundary tests, safe file validation, and deployment verification.
- Stretch work begins only when essential stories meet their acceptance criteria and the team has capacity.

## Development and Verification Commands

Run from the project directory in Ubuntu/WSL:

```bash
bundle install
bundle exec rails db:prepare
bundle exec rails server
```

Run the automated checks:

```bash
bundle exec rspec
bundle exec cucumber
bundle exec rubocop app/models app/controllers app/helpers spec features
bundle exec bundler-audit check
```
