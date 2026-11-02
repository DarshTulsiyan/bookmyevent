# BookMyEvent Project Plan

## Product vision

BookMyEvent is an event discovery and ticketing platform. Visitors can find approved upcoming events. Attendees can book tickets and view their bookings. Organizers can create and manage events, define ticket tiers, and support event entry. Administrators can review submitted events and oversee platform activity.

## Product goals

- Provide secure registration, login, logout, and role-appropriate access.
- Let organizers create events and ticket tiers without exceeding event capacity.
- Require administrative review before an event is published.
- Make approved upcoming events discoverable to the public.
- Let attendees purchase tickets with reliable, all-or-nothing capacity handling.
- Give attendees and organizers useful views of their own tickets, events, and attendance activity.
- Prevent unauthorized access to user, event, booking, and moderation information.
- Deliver a usable, tested, and deployable application.

## User roles

- **Visitor:** Browse public events and event details; create an attendee or organizer account.
- **Attendee:** Browse approved events, book tickets, and view their own bookings and tickets.
- **Organizer:** Create events, manage owned events and ticket tiers, view event activity, and check in attendees.
- **Admin:** Review pending events, approve or reject them, and oversee users and system activity.

## Product backlog

Priorities use lower numbers for higher priority. Story points are relative estimates.

### US-01: Sign up, log in, and log out

**Priority 1 | 5 Points | Sprint 1 | Role: All users**

**User Story:** As a user, I want to create an account, log in, and log out securely so that I can access features specific to my role.

**Acceptance Criteria:**

- A user can register with valid details as an attendee or organizer.
- Admin cannot be selected through public registration.
- A user can log in with valid credentials and gets access appropriate to their role.
- Invalid credentials do not create a session and display an understandable error.
- A user can log out and the session is cleared.
- Suspended accounts cannot sign in.

### US-02: Organizer creates an event

**Priority 2 | 5 Points | Sprint 1 | Role: Organizer**

**User Story:** As an organizer, I want to create an event with its details and capacity so that it can be submitted for approval.

**Acceptance Criteria:**

- Organizer can enter title, description, venue, start date/time, and total capacity.
- Valid event creation assigns a unique event identifier.
- A newly created event starts in pending approval status.
- Invalid or missing event details are rejected with useful validation errors.
- The organizer cannot set the event to approved or rejected through submitted form values.

### US-03: Organizer defines ticket tiers

**Priority 3 | 5 Points | Sprint 1 | Role: Organizer**

**User Story:** As an organizer, I want to define ticket tiers with separate capacities so that I can offer ticket options without exceeding the event capacity.

**Acceptance Criteria:**

- Organizer can create ticket tiers with a name and capacity.
- Each tier receives a unique identifier and belongs to one event.
- Tier names are unique within an event.
- The sum of tier capacities cannot exceed the event capacity.
- Capacity cannot be reduced below tickets already sold.
- Tiers with sold tickets cannot be deleted.
- Invalid tier changes display validation errors and do not partially save.

### US-04: Attendee browses public events

**Priority 4 | 2 Points | Sprint 1 | Role: Attendee / Visitor**

**User Story:** As an attendee, I want to browse approved public events so that I can view event details and available spots.

**Acceptance Criteria:**

- Visitors can access the event list without logging in.
- Public listing includes approved events whose start time is in the future, soonest first.
- Pending, rejected, and past events are excluded from public listings.
- Each listing shows title, date/time, venue, seats remaining, and a link to details.
- Event details show full event information and each ticket tier.
- Each tier shows its name and seats remaining.
- Available tiers provide a Book form that submits the selected tier to the ticket booking endpoint.
- Sold-out tiers display “Sold Out” and cannot be booked.
- Direct requests for events that are not publicly visible return not found.
- An empty listing has a clear empty state.

### US-05: Attendee books tickets

**Priority 5 | 5 Points | Sprint 1 | Role: Attendee**

**User Story:** As an attendee, I want to book one or more tickets across event tiers in one booking so that I receive one booking ID and a unique ticket ID for every seat.

**Acceptance Criteria:**

- Attendee can select quantities from one or more tiers of an approved event.
- A successful checkout creates one booking with a unique booking ID.
- A ticket is created for each seat, each with a unique ticket ID linked to the booking.
- The booking and tickets belong to the signed-in attendee and selected event.
- Tier availability is decremented consistently.
- If any tier lacks sufficient seats, the entire booking fails and no tickets or partial booking are created.
- My Tickets displays each booking ID and its ticket IDs.
- Organizers and admins cannot book as attendees unless explicitly supported by role rules.

### US-06: Organizer checks in an attendee

**Priority 8 | 5 Points | Sprint 2 | Role: Organizer**

**User Story:** As an organizer, I want to check in attendees using a ticket ID or attendee name so that I can verify entry at the event.

**Acceptance Criteria:**

- Organizer can access check-in for an event they own.
- Organizer can search or submit a ticket ID or attendee name.
- System verifies the ticket belongs to the organizer's event.
- Successful check-in records the time and displays confirmation.
- Invalid tickets and tickets from another event are rejected without changing their state.

### US-07: Admin approves or rejects events

**Priority 7 | 3 Points | Sprint 1 | Role: Admin**

**User Story:** As an admin, I want to approve or reject submitted events so that only valid events are published.

**Acceptance Criteria:**

- Admin can review pending events and their details.
- Admin can approve or reject an event that is pending.
- Approved future events become publicly visible.
- Rejected events remain hidden from public views.
- Admin can see pending, published, and rejected events in separate lists.
- Event details display status and appropriate review controls.
- Non-admin users cannot access moderation pages or perform moderation actions.
- Invalid, repeated, or missing-event moderation requests do not change event state.

### US-08: Show sold-out status

**Priority 6 | 2 Points | Sprint 1 | Role: Attendee**

**User Story:** As an attendee, I want to see a clear sold-out message when capacity is full so that I know I cannot register for unavailable tickets.

**Acceptance Criteria:**

- A tier with no seats remaining is marked Sold Out.
- The booking form does not offer a selectable quantity for a sold-out tier.
- Server-side booking rejects a sold-out tier even if a crafted request is submitted.
- A rejected booking creates no booking or ticket records.
- Remaining ticket tiers can still be booked if they have capacity.

### US-09: Reject duplicate check-in

**Priority 9 | 2 Points | Sprint 2 | Role: Organizer**

**User Story:** As an organizer, I want duplicate check-in attempts rejected so that a ticket cannot be reused.

**Acceptance Criteria:**

- A ticket can be checked in only once.
- A repeat check-in displays an already-checked-in error.
- The original check-in timestamp and record remain unchanged.
- A failed duplicate attempt does not affect other tickets.

### US-10: Protect restricted pages

**Priority 10 | 2 Points | Sprint 2 | Role: All users**

**User Story:** As a user, I want restricted pages to block unauthorized access so that role privileges and private data are protected.

**Acceptance Criteria:**

- Unauthenticated users are directed to sign in before accessing protected pages.
- Authenticated users without the required role are denied access.
- Users cannot read or modify another user's private bookings, events, or account data.
- The application displays a clear access error or redirects appropriately.
- After login, a user may return to their originally requested page when safe and authorized.
- Authorization is enforced on the server for every protected action, not only hidden in the interface.

### US-11: Organizer dashboard

**Priority 11 | 3 Points | Sprint 2 | Role: Organizer**

**User Story:** As an organizer, I want a dashboard of my events so that I can track registrations and manage check-ins.

**Acceptance Criteria:**

- Dashboard lists only events owned by the signed-in organizer.
- Each event shows title, date, status, capacity, and attendee count.
- Organizer can open owned event details and check-in pages.
- Organizer cannot view or manage events owned by another organizer.
- Dashboard displays ticket statistics when applicable.
- Newly submitted events show Pending Approval status.

### US-12: Admin dashboard

**Priority 12 | 3 Points | Sprint 2 | Role: Admin**

**User Story:** As an admin, I want a dashboard showing system statistics and moderation queues so that I can manage the platform.

**Acceptance Criteria:**

- Dashboard displays total users, total events, and total registrations.
- Dashboard displays role-wise user totals.
- Admin can navigate to users and pending, published, and rejected event lists.
- User list shows names, emails, roles, and account status where available.
- Admin-only information is not exposed to visitors or non-admin roles.
- User management actions are available only when implemented and authorized by the product requirements.

### US-13: Waitlist for sold-out events (stretch)

**Priority 13 | 5 Points | Sprint 2 | Role: Attendee**

**User Story:** As an attendee, I want to join a waitlist for sold-out events so that I can receive a ticket if a place becomes available.

**Acceptance Criteria:**

- An eligible attendee can join the waitlist for a sold-out event or tier.
- Waitlist entries have a stable order and prevent duplicate active entries by the same attendee.
- When capacity becomes available, the next eligible attendee is offered or assigned the place according to the agreed business rule.
- Promotion creates a valid ticket and records the attendee's booking.
- Attendees can see their waitlist status.
- Waitlist behavior is concurrency-safe and does not oversell capacity.

### US-14: Organizer event analytics (stretch)

**Priority 14 | 5 Points | Sprint 2 | Role: Organizer**

**User Story:** As an organizer, I want analytics for my events so that I can measure registrations and attendance.

**Acceptance Criteria:**

- Analytics show registration totals and ticket-tier breakdowns.
- Analytics show checked-in count and check-in percentage.
- Check-in percentage is calculated as checked-in tickets divided by registrations, multiplied by 100.
- Empty registration totals do not cause a divide-by-zero error.
- Only the event owner and authorized admins can access the analytics.

### US-15: Upload venue booking proof (stretch)

**Priority 15 | 3 Points | Sprint 2 | Role: Organizer / Admin**

**User Story:** As an organizer, I want to upload proof that I booked the venue so that an admin can verify it before approving my event.

**Acceptance Criteria:**

- Organizer can attach venue booking proof when creating or editing an event.
- PDF, JPG, and PNG files are accepted; unsupported types and oversized files are rejected with a useful error.
- An event cannot be approved until required proof is attached.
- Admin can view or download proof while reviewing the event.
- Only the event's organizer and authorized admins can access the proof.
- Replacing or removing proof follows the agreed review and retention rules.

## Sprint plan

### Sprint 1 — Core event marketplace

- US-01: Authentication and role access foundations — 5 points.
- US-02: Organizer event creation — 5 points.
- US-03: Ticket tiers and capacity — 5 points.
- US-04: Public event browsing — 2 points.
- US-05: Ticket booking — 5 points.
- US-07: Event approval and rejection — 3 points.
- US-08: Sold-out handling — 2 points.

**Sprint 1 planned total: 27 points.**

### Sprint 2 — Operations and extensions

- US-06: Organizer check-in — 5 points.
- US-09: Duplicate check-in rejection — 2 points.
- US-10: Unauthorized access handling — 2 points.
- US-11: Organizer dashboard — 3 points.
- US-12: Admin dashboard — 3 points.
- US-13: Waitlist (stretch) — 5 points.
- US-14: Organizer analytics (stretch) — 5 points.
- US-15: Venue booking proof (stretch) — 3 points.

**Sprint 2 planned total: 28 points, including 13 stretch points.**

## Quality and Definition of Done

Every increment must satisfy the following before it is considered complete:

- Acceptance tests cover happy and sad paths for the backlog item.
- All applicable tests pass.
- Cucumber acceptance-test code coverage is at least 90%.
- RSpec unit-test code coverage is at least 90%.
- Combined test-suite code coverage is at least 90%.
- RuboCop reports zero offenses in models, controllers, helpers, and test code.
- Role and ownership authorization is tested for new protected routes and actions.
- The increment is deployed to the production environment and its deployed behavior is verified.
- User-facing setup or behavior documentation is updated when needed.

## Engineering and delivery approach

- Keep controllers focused on request handling and authorization; place business rules in models or dedicated service objects where appropriate.
- Enforce critical invariants in both application validation and database constraints when feasible.
- Make booking operations transactional and concurrency-safe so simultaneous requests cannot oversell tickets.
- Scope organizer queries and mutations to the signed-in organizer's events.
- Keep admin provisioning separate from public signup and manage production credentials securely.
- Use semantic HTML and accessible labels, headings, tables, and status messages.
- Keep acceptance scenarios concise, independent, unambiguous, and understandable as user behavior.
- Keep RSpec examples fast, isolated, repeatable, and self-validating.
- Run security scans, lint, RSpec, and Cucumber in continuous integration.
- Deploy through the configured production pipeline; verify required environment variables and database migrations before release.

## Key risks and responses

| Risk | Response |
|---|---|
| Two bookings compete for the last seats | Lock affected ticket tiers, check availability inside a transaction, and reject the entire booking if any requested tier is unavailable. |
| Users access another organizer's events | Scope every organizer list, detail, edit, update, and check-in action to the current organizer. |
| Unreviewed events appear publicly | Default new events to pending and expose only approved future events publicly. |
| Duplicate ticket use at entry | Persist check-in state and reject repeat check-in attempts without overwriting the original timestamp. |
| Sensitive admin credentials are exposed | Never allow admin self-registration or ship a shared default production password; use private provisioning and secret management. |
| CI passes while production configuration is incomplete | Verify production environment configuration, migrations, deployment health, and core user flows after release. |

## Local development and checks

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
