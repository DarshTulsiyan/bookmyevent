# BookMyEvent

BookMyEvent is a Ruby on Rails application for browsing events and managing event tickets. Users can register as attendees or organizers. Admins use a protected dashboard to review pending events.

## Run locally in Ubuntu (WSL)

From the Ubuntu terminal, go to the project directory and start Rails:

```bash
cd ~/bookmyevent
bundle install
bundle exec rails db:prepare
bundle exec rails server
```

Open [http://localhost:3000](http://localhost:3000) in your browser. PostgreSQL must be running and configured for the app; see `config/database.yml` for the local database settings and the `DEV_DATABASE_URL` option.

## Admin access

Public signup is limited to attendee and organizer accounts. In development, run the seed to create the default admin account:

```bash
bundle exec rails db:seed
```

Sign in with:

- Email: `admin@bookmyevent.com`
- Password: `admin@123`

Then open [http://localhost:3000/admin](http://localhost:3000/admin). The protected admin area includes a dashboard summary with a role breakdown, a user list, a pending-events view, and a separate published-events view. Event approval/rejection and user suspension actions are not implemented yet.

The default account is created only in the development environment; it is not created in production.
