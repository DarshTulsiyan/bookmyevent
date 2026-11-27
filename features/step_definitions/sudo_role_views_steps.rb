Given("a sudo account exists") do
  @sudo_user = FactoryBot.create(:user, :sudo, name: "BookMyEvent Superuser")
end

When("the sudo account logs in") do
  visit login_path
  fill_in "Email", with: @sudo_user.email
  fill_in "Password", with: "Password123!"
  click_button "Log in"
end

Then("the sudo account can open attendee, organizer, and admin workspaces") do
  expect(page).to have_link("My Tickets", href: my_tickets_path)
  expect(page).to have_link("Admin dashboard", href: admin_path)
  expect(page).to have_link("Create event", href: new_event_path)

  click_link "Admin dashboard"
  expect(page).to have_content("Admin dashboard")

  click_link "My account"
  expect(page).to have_content("Role workspaces")

  click_link "Attendee workspace"
  expect(page).to have_content("My Tickets")

  click_link "My account"
  click_link "Organizer workspace"
  expect(page).to have_content("Create an event")
end
