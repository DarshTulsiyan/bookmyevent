### What Went Well
Core MVP Execution: Delivered authentication (US-01), organizer event creation (US-02), ticket tier definition (US-03), attendee browsing/registration (US-04, US-05), sold-out enforcement (US-08), and admin event moderation (US-07).

Pipeline & Quality Assurance: Successfully established CI/CD via GitHub Actions with RuboCop linting, automated RSpec/Cucumber test runs, and continuous deployment to Render.

Test Coverage: Maintained code coverage above the mandatory 90% threshold using SimpleCov.

### What Could Be Improved
Capacity Race Conditions: Concurrency edge cases required implementing pessimistic database locking (with_lock / SELECT FOR UPDATE) to prevent over-registration near full capacity.

Deployment & Environment Setup: Staging database configurations on Render required additional time to set up during early sprint days.

Story Point Calibration: Initial user authentication and role-based authorization setup required more effort than originally estimated.