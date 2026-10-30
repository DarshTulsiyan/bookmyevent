Given("I am logged in as an organizer") do
  @organizer = FactoryBot.create(:user, :organizer)
  visit login_path
  fill_in "Email", with: @organizer.email
  fill_in "Password", with: "Password123!"
  click_button "Log in"
end

When("I visit the new event page") do
  visit new_event_path
end

When("I create an event with valid details") do
  visit new_event_path
  fill_in "Title", with: "Spring Concert"
  fill_in "Description", with: "An evening of live music."
  fill_in "Venue", with: "Rudder Auditorium"
  fill_in "Starts at", with: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")
  fill_in "Total capacity", with: "100"
  click_button "Create Event"
end

When("I create an event without a title") do
  visit new_event_path
  fill_in "Venue", with: "Rudder Auditorium"
  fill_in "Starts at", with: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")
  fill_in "Total capacity", with: "100"
  click_button "Create Event"
end

Given("an approved event {string} exists") do |title|
  FactoryBot.create(:event, title: title, status: :approved)
end

When("I browse events and open {string}") do |title|
  click_link "Events"
  click_link title
end

Then("the event page should show {string}") do |text|
  expect(page).to have_content(text)
end
