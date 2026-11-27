Feature: Admin access requests
  Visitors request access with a new email, and only the designated administrator can decide.

  Scenario: A visitor receives admin access after approval
    Given a designated seeded administrator exists
    When a visitor submits a valid admin access request
    And the designated administrator approves the request
    Then the applicant can sign in and open the admin dashboard

  Scenario: A registered account cannot request another role by email
    Given an attendee account exists for admin access testing
    When that attendee submits an admin access request
    Then the application is rejected because the email is already registered

  Scenario: An ordinary admin cannot approve requests
    Given a pending admin access request exists
    And an ordinary admin account exists
    When the ordinary admin opens the request review page
    Then the ordinary admin is denied access and the request stays pending
