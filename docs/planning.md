# BookMyEvent Project Plan

## Reference documents

This plan uses the latest project references fetched from `origin/develop` at commit `57bba0c`:

- `docs/user_stories.md` — product backlog, priorities, story points, and sprint assignments.
- `docs/design.md` — architecture, data model, role access, and request flows.
- `docs/retrospective.md` — delivery notes, CI/CD, coverage, and lessons learned.

The Organizer “My Events” story below preserves the priority, points, sprint, and acceptance criteria supplied for that story.

## Project goal

BookMyEvent is a Ruby on Rails and PostgreSQL application for event creation, approval, public discovery, ticket bookings, and role-specific event management. Its primary roles are Attendee, Organizer, and Admin.

## Backlog stories

### US-04: Attendee browses public events

**Priority 4 | 2 Points | Sprint 1**

**Role:** Attendee / Visitor

**User Story:** As an attendee, I want to browse approved public events so that I can view event details and available spots.

**Acceptance Criteria:**

- Anyone can open the public event list without logging in.
- The home page and `/events` show approved events that start in the future.
- Events are ordered by start time, soonest first.
- Each event shows its title, date and time, venue, seats remaining, and a link to details.
- An event details page shows full event details and one row for each ticket tier.
- Each tier row shows its name and seats remaining.
- Available tiers provide a Book form that submits `ticket_tier_id` to `/tickets`.
- Sold-out tiers show “Sold Out” and do not offer an active booking control.
- Pending, rejected, and past events are omitted from public lists.
- Direct requests for events that are not publicly visible return `404 Not Found`.
- Booking continues to enforce attendee login and existing capacity rules.
- The event listing provides a clear empty state when there are no public events.

**Scope:** Public event listing → event details → ticket tier availability → booking entry point.

**Technical Scope:**

- `Event.publicly_visible`: approved future events, ordered soonest first.
- `EventsController#index` and `#show`.
- Root path and `GET /events` use the public event listing.
- Views: `events/index`, `events/show`, and `events/_tier_row`.
- RSpec scope and request specs; Cucumber visitor scenarios for visible and hidden events.

### US-07: Admin approves or rejects events

**Priority 7 | 3 Points | Sprint 1**

**Role:** Admin

**User Story:** As an admin, I want to approve or reject submitted events so that only valid events are published.

**Acceptance Criteria:**

- Admins can review events awaiting approval.
- Admins can approve a pending event; its status becomes approved and it becomes publicly visible if it is in the future.
- Admins can reject a pending event; its status becomes rejected and it remains hidden from public browsing.
- Only admins can perform approval or rejection actions.
- Non-admin attempts are denied and do not change event status.
- Only pending events can be moderated; missing events return not found.
- Admins can review pending, published, and rejected events in separate lists.
- Event details display the current status and appropriate admin review controls.

**Scope:** Pending event queue → inspect event → approve or reject → review resulting status.

**Technical Scope:**

- `EventsController#approve` and `#reject` with role and state checks.
- `Event` status transition methods and persistence.
- Admin event list/detail views and status-specific navigation.
- RSpec request specs and Cucumber scenarios for approval, rejection, and denied access.

### Organizer: View and manage my events

**Priority 1 | 3 Points | Sprint 1**

**Role:** Organizer

**User Story:** As an Organizer, I want to view my created events and their approval status so that I can track events submitted for administrative approval and manage their information.

**Acceptance Criteria:**

- Organizer can access `/my-events` to view their events.
- Dashboard displays only events created by the logged-in organizer.
- Organizer can view event details, including title, venue, date, capacity, and status.
- Newly submitted events display a Pending Approval status.
- Organizer can edit their own events.
- Organizer cannot edit events belonging to other organizers.
- System validates event updates before saving.
- Dashboard displays ticket statistics where applicable.

**Scope:** Create event → save as pending → view My Events → track pending approval status.

**Technical Scope:**

- `EventsController`: `mine()`, `edit()`, and `update()`.
- Event/Organizer associations and event validations.
- Organizer-scoped event lookup for list, detail, and edit/update actions.
- Add request/model specs and Cucumber happy/sad path scenarios for ownership, validation, and status visibility.

### US-12: Admin dashboard

**Priority 12 | 3 Points | Sprint 2**

**Role:** Admin

**User Story:** As an admin, I want a dashboard showing system statistics and moderation queues so that I can manage the platform.

**Acceptance Criteria:**

- Admin dashboard displays total users, total events, and total registrations.
- Dashboard displays role-wise user counts for attendee, organizer, and admin accounts.
- Admin can navigate to the user list and pending, published, and rejected event lists.
- User list displays each account’s name, email, role, and account status where available.
- Dashboard and user data are restricted to admins.
- Non-admin users are denied access to admin pages.

**Scope:** Admin login → dashboard metrics and role breakdown → user list → event moderation queues.

**Technical Scope:**

- `AdminController` dashboard, user list, and event status list actions.
- Admin dashboard and user table views with semantic HTML structure.
- Role authorization for every admin route.
- RSpec request tests and Cucumber scenarios for access, summaries, and lists.

## Local development admin account

The development seed account is for local testing only:

- Email: `admin@bookmyevent.com`
- Password: `admin@123`

Create or refresh it in the development environment with `bundle exec rails db:seed`. Public signup must not grant the admin role. Do not deploy these shared credentials or create this default account in production; provision production administrators through a private, controlled process.

## Definition of Done

For each backlog item:

- Acceptance tests cover the item's happy and sad paths.
- All tests pass.
- Cucumber acceptance-test coverage is at least 90%.
- RSpec unit-test coverage is at least 90%.
- Total coverage is at least 90%.
- RuboCop reports zero offenses in models, controllers, helpers, and tests.
- The increment is deployed to the production environment.

Coverage percentages must be reported from the project's coverage tooling. The `develop` retrospective records that the team maintained coverage above 90%; verify coverage for the current branch and each increment rather than assuming that result carries forward.

## Development and verification commands

Run in the Ubuntu/WSL project directory:

```bash
cd ~/bookmyevent
bundle install
bundle exec rails db:prepare
bundle exec rails server
```

Run tests and quality checks:

```bash
bundle exec rspec
bundle exec cucumber
bundle exec rubocop app/models app/controllers app/helpers spec features
bundle exec bundler-audit check
```

## Delivery notes from `develop`

- The application uses server-rendered Rails ERB views with PostgreSQL.
- Authentication and role checks are handled by the Rails application.
- RSpec and Cucumber are the project's unit/request and acceptance test tools.
- GitHub Actions runs Ruby security scans, JavaScript dependency scanning, and RuboCop.
- The design document identifies Render as the continuous deployment target.
