Feature: User authentication
  Users can register, log in, and log out.

  Scenario: Successful registration
    Given I visit the registration page
    When I register with valid account details
    Then the authentication page should show "Account created successfully"
    And the authentication page should show "Signed in as Darsh"

  Scenario: Missing registration details
    Given I visit the registration page
    When I submit the registration form without details
    Then the authentication page should show "Please correct the following"

  Scenario: Incorrect password
    Given an attendee has registered
    When I try to log in with the wrong password
    Then the authentication page should show "Invalid email or password"

  Scenario: Successful logout
    Given I am logged in to my attendee account
    When I log out of my account
    Then the authentication page should show "Logged out successfully"
    And the login link should be visible