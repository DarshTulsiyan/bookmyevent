Given("an admin account exists") do
  @admin = FactoryBot.create(:user, name: "Admin User", role: :admin)
end

Given("attendee and organizer accounts exist") do
  @attendee = FactoryBot.create(:user, name: "Feature Attendee", role: :attendee)
  @organizer = FactoryBot.create(:user, name: "Feature Organizer", role: :organizer)
end

Given("a pending event {string} exists") do |title|
  @admin_event = FactoryBot.create(:event, title: title, status: :pending)
end

Given("a published event {string} exists") do |title|
  @published_event = FactoryBot.create(:event, title: title, status: :approved)
end

Given("a rejected event {string} exists") do |title|
  @rejected_event = FactoryBot.create(:event, title: title, status: :rejected)
end

When("the admin logs in") do
  visit login_path
  fill_in "Email", with: @admin.email
  fill_in "Password", with: "Password123!"
  click_button "Log in"
end

When("the admin opens the dashboard") do
  visit admin_path
end

When("the admin opens the users page") do
  visit admin_users_path
end

When("the admin opens the pending events page") do
  visit admin_pending_events_path
end

When("the admin opens the published events page") do
  visit admin_published_events_path
end

When("the admin opens the rejected events page") do
  visit admin_rejected_events_path
end

When("the admin opens the details for {string}") do |title|
  event = Event.find_by!(title: title)
  visit event_path(event)
end

Then("the admin dashboard link is visible") do
  expect(page).to have_link("Admin dashboard", href: admin_path)
end

Then("the dashboard shows summaries, roles, and user accounts") do
  [ "Summary", "Users by role", "User accounts", "Admin", "Attendee", "Organizer",
    @admin.email, @attendee.email, @organizer.email ].each do |content|
    expect(page).to have_content(content)
  end
end

Then("the user list shows names, roles, and account status") do
  [ "Feature Attendee", "Attendee", "Feature Organizer", "Organizer", "Active" ].each do |content|
    expect(page).to have_content(content)
  end
end

Then("the event appears with enabled approve and reject buttons") do
  within(page.find("tr", text: @admin_event.title)) do
    expect(page).to have_content("Pending approval")
    expect(page).to have_button("Approve & publish", disabled: false)
    expect(page).to have_button("Reject", disabled: false)
  end
end

Then("the event details show pending status and enabled review buttons") do
  expect(page).to have_content(@admin_event.title)
  expect(page).to have_content("Pending approval")
  expect(page).to have_button("Approve & publish", disabled: false)
  expect(page).to have_button("Reject", disabled: false)
end

Then("only the published event appears") do
  expect(page).to have_content(@published_event.title)
  expect(page).to have_content("Approved")
  expect(page).not_to have_content(@admin_event&.title || "Awaiting Approval")
end

Then("only the rejected event appears") do
  expect(page).to have_content(@rejected_event.title)
  expect(page).to have_content("Rejected")
  expect(page).not_to have_content(@admin_event&.title || "Awaiting Approval")
end

Then("an authorization error is shown") do
  expect(page).to have_content("Not authorized")
end
