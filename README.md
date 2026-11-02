# BookMyEvent

BookMyEvent is an event booking application built with Ruby on Rails. Organizers create events and ticket tiers, admins approve or reject events, and attendees browse approved events and book tickets.

## Main Features

- Register and log in as an attendee or organizer.
- Create and edit events as their organizer.
- Add, update, and remove ticket tiers within event capacity limits.
- Review pending events and approve or reject them as an admin.
- Browse approved upcoming events and view available seats.
- Book multiple tickets across available tiers in one booking.
- View personal bookings and individual Ticket IDs on the My Tickets page.
- Display sold-out tiers and prevent bookings beyond capacity.
- Show validation errors and booking feedback.

## Requirements

- Ruby **4.0.6**
- Ruby on Rails **8.1.4** (installed through Bundler)
- Bundler **4.0.23**
- PostgreSQL installed and running

The required gem versions are recorded in `Gemfile.lock`.

## Installation and Setup

### 1. Open the project

Clone the repository using its GitHub URL, then enter the project directory:

```bash
cd bookmyevent
```

Confirm that the correct Ruby version is active:

```bash
ruby -v
```

### 2. Install dependencies

```bash
gem install bundler -v 4.0.23
bundle _4.0.23_ install
```

### 3. Start PostgreSQL

If PostgreSQL is not installed on macOS, install and start it with Homebrew:

```bash
brew install postgresql@16
brew services start postgresql@16
```

If PostgreSQL is already installed, start your existing server instead.

### 4. Set up the database

```bash
bin/rails db:prepare
```

By default, the app uses the local PostgreSQL server with these databases:

- Development: `bookmyevent_development`
- Test: `bookmyevent_test`

Connection settings are in `config/database.yml`. For a different development server, set `DEV_DATABASE_URL` in an untracked `.env` file.

### 5. Set up admin access

The development seed provisions a local admin account:

```bash
bin/rails db:seed
```

Obtain admin access details privately from the project maintainer. Public signup only creates attendee or organizer accounts. The development seed does not create admins in production.

## Running the Application

Start the Rails development server:

```bash
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000) in a browser. Press `Ctrl+C` in the terminal to stop the server.

## Using the Application

- **Organizers:** Create an event, add ticket tiers on its edit page, and wait for admin approval.
- **Admins:** Open the Admin dashboard to review pending events and approve or reject them.
- **Attendees:** Browse Events, select ticket quantities, and book. View the resulting bookings and Ticket IDs under My Tickets.

Only approved upcoming events appear in public listings. Full tiers show **Sold Out**. If seats sell out before a booking is submitted, the app displays an error without creating a partial booking.

## Running Tests

The project uses RSpec for model and request tests, and Cucumber for user acceptance scenarios. PostgreSQL must be running, and tests must use a separate test database.

Prepare the test database and run both suites:

```bash
RAILS_ENV=test bin/rails db:prepare
bundle exec rspec
bundle exec cucumber
```

To run a specific test file or feature:

```bash
bundle exec rspec spec/models/event_spec.rb
bundle exec rspec spec/requests/sold_out_spec.rb
bundle exec cucumber features/event_approval.feature
bundle exec cucumber features/sold_out.feature
```

Tests cover authentication, permissions, event management, approval decisions, ticket tiers, bookings, sold-out behavior, and concurrent booking requests.

SimpleCov is included as a dependency, but coverage reporting is not currently configured.

## Code Quality Checks

```bash
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit
```

GitHub Actions runs lint and security checks on pull requests and pushes to `main`. RSpec and Cucumber currently need to be run separately.

## Project Structure

```text
app/models/          Models and database relationships
app/controllers/     Request handling and authorization
app/views/           Pages, forms, and shared templates
app/assets/          Stylesheets and images
config/routes.rb     Application routes
config/database.yml  Database configuration
db/                  Migrations, schemas, and seeds
spec/                RSpec tests and FactoryBot factories
features/            Cucumber scenarios and step definitions
.github/workflows/   CI configuration
```

The main models are `User`, `Event`, `TicketTier`, `Booking`, and `Ticket`. A booking groups one or more individual tickets for an attendee and an event.

## About

Software Engineering Project 2.
