Given("I visit the registration page") do
  visit signup_path
end

When("I register with valid account details") do
  fill_in "Name", with: "Darsh"
  fill_in "Email", with: "darsh@example.com"
  fill_in "Password", with: "Password123!", exact: true
  fill_in "Confirm password", with: "Password123!"
  select "Attendee", from: "Account type"

  click_button "Create account"
end

When("I submit the registration form without details") do
  click_button "Create account"
end

Given("an attendee has registered") do
  @attendee = FactoryBot.create(:user)
end

When("I try to log in with the wrong password") do
  visit login_path

  fill_in "Email", with: @attendee.email
  fill_in "Password", with: "WrongPassword"

  click_button "Log in"
end

Given("I am logged in to my attendee account") do
  @attendee = FactoryBot.create(:user)

  visit login_path

  fill_in "Email", with: @attendee.email
  fill_in "Password", with: "Password123!"

  click_button "Log in"
end

When("I log out of my account") do
  click_button "Log out"
end

Then("the authentication page should show {string}") do |text|
  expect(page).to have_content(text)
end

Then("the login link should be visible") do
  expect(page).to have_link("Log in", href: login_path)
end
