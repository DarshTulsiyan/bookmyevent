Given("a designated seeded administrator exists") do
  @access_reviewer = FactoryBot.create(
    :user,
    role: :admin,
    admin_access_request_reviewer: true,
    name: "Seeded Administrator"
  )
  @access_applicant = {
    name: "Access Applicant",
    email: "request-applicant@example.com",
    reason: "I coordinate event operations.",
    password: "ApplicantPass123!",
    password_confirmation: "ApplicantPass123!"
  }
end

When("a visitor submits a valid admin access request") do
  visit new_access_application_path
  fill_in "Name", with: @access_applicant[:name]
  fill_in "Email", with: @access_applicant[:email]
  fill_in "Why do you need admin access?", with: @access_applicant[:reason]
  fill_in "Choose a password", with: @access_applicant[:password]
  fill_in "Confirm password", with: @access_applicant[:password_confirmation]
  click_button "Submit request"
end

When("the designated administrator approves the request") do
  visit login_path
  fill_in "Email", with: @access_reviewer.email
  fill_in "Password", with: "Password123!"
  click_button "Log in"
  visit admin_access_requests_path
  click_link @access_applicant[:name]
  click_button "Approve admin access"
end

Then("the applicant can sign in and open the admin dashboard") do
  expect(page).to have_content("now has admin access")
  page.driver.submit :delete, logout_path, {}
  visit login_path
  fill_in "Email", with: @access_applicant[:email]
  fill_in "Password", with: @access_applicant[:password]
  click_button "Log in"

  expect(page).to have_link("Admin dashboard", href: admin_path)
  visit admin_path
  expect(page).to have_content("Admin dashboard")
end

Given("an attendee account exists for admin access testing") do
  @registered_attendee = FactoryBot.create(:user, email: "registered-attendee@example.com")
end

When("that attendee submits an admin access request") do
  visit new_access_application_path
  fill_in "Name", with: "Registered Attendee"
  fill_in "Email", with: @registered_attendee.email
  fill_in "Why do you need admin access?", with: "I need additional privileges."
  fill_in "Choose a password", with: "ApplicantPass123!"
  fill_in "Confirm password", with: "ApplicantPass123!"
  click_button "Submit request"
end

Then("the application is rejected because the email is already registered") do
  expect(page).to have_content("Email is already registered")
  expect(AdminAccessRequest.count).to eq(0)
  expect(User.find_by(email: @registered_attendee.email)).to be_attendee
end

Given("a pending admin access request exists") do
  @pending_access_request = FactoryBot.create(:admin_access_request)
end

Given("an ordinary admin account exists") do
  @ordinary_admin = FactoryBot.create(:user, role: :admin, admin_access_request_reviewer: false)
end

When("the ordinary admin opens the request review page") do
  visit login_path
  fill_in "Email", with: @ordinary_admin.email
  fill_in "Password", with: "Password123!"
  click_button "Log in"
  visit admin_access_requests_path
end

Then("the ordinary admin is denied access and the request stays pending") do
  expect(page).to have_content("Not authorized")
  expect(@pending_access_request.reload).to be_pending
end
