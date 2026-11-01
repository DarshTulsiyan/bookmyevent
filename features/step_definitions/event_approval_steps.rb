When("the admin chooses {string} for {string}") do |button, title|
  within(page.find("tr", text: title)) do
    click_button button
  end
end

Then("{string} is absent from the pending events table") do |title|
  expect(page).to have_current_path(admin_pending_events_path)
  expect(page).not_to have_link(title)
end

When("I open the public events listing") do
  visit events_path
end

Then("the public listing should include {string}") do |title|
  expect(page).to have_link(title)
end

Then("the public listing should not include {string}") do |title|
  expect(page).not_to have_link(title)
end

When("the event owner logs in and opens the event editor") do
  owner = @admin_event.organizer

  visit login_path
  fill_in "Email", with: owner.email
  fill_in "Password", with: "Password123!"
  click_button "Log in"

  visit edit_event_path(@admin_event)
end