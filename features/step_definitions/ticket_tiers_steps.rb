Given("an organizer owns an event with a capacity of {int}") do |capacity|
  @organizer = FactoryBot.create(:user, :organizer)
  @event = FactoryBot.create(
    :event,
    organizer: @organizer,
    total_capacity: capacity
  )

  visit login_path
  fill_in "Email", with: @organizer.email
  fill_in "Password", with: "Password123!"
  click_button "Log in"

  visit edit_event_path(@event)
end

When("the organizer adds a {string} tier with capacity {int}") do |name, capacity|
  all('input[name="ticket_tier[name]"]').first.set(name)
  all('input[name="ticket_tier[capacity]"]').first.set(capacity)
  click_button "Add tier"
end

Given("the event already has a {string} tier with capacity {int}") do |name, capacity|
  FactoryBot.create(
    :ticket_tier,
    event: @event,
    name: name,
    capacity: capacity
  )

  visit edit_event_path(@event)
end

Then("the event should have {int} ticket tiers") do |count|
  expect(@event.ticket_tiers.count).to eq(count)
end

Then("the event should have {int} remaining unallocated seats") do |seats|
  allocated = @event.ticket_tiers.sum(:capacity)
  unallocated = @event.total_capacity - allocated

  expect(unallocated).to eq(seats)
end

Then("the ticket tier should not be saved") do
  expect(@event.ticket_tiers.count).to eq(1)
end

Then("a capacity validation error should be shown") do
  expect(page).to have_content(
    "Capacity exceeds the event's total capacity"
  )
end

When("the organizer updates the {string} tier to capacity {int}") do |name, capacity|
  within("#ticket-tiers") do
    tier_section = find("section", text: name, match: :prefer_exact)

    within(tier_section) do
      fill_in "Capacity", with: capacity
      click_button "Update tier"
    end
  end
end

Then("the {string} tier should have capacity {int}") do |name, capacity|
  tier = @event.ticket_tiers.find_by!(name: name)
  expect(tier.capacity).to eq(capacity)
end

Then("the {string} tier should still have capacity {int}") do |name, capacity|
  tier = @event.ticket_tiers.find_by!(name: name)
  expect(tier.capacity).to eq(capacity)
end

When("the organizer deletes the {string} tier") do |name|
  within("#ticket-tiers") do
    tier_section = find("section", text: name, match: :prefer_exact)

    within(tier_section) do
      click_button "Delete tier"
    end
  end
end

Then("the {string} tier should still exist") do |name|
  expect(@event.ticket_tiers.exists?(name: name)).to be true
end

Given("the {string} tier has a sold ticket") do |name|
  tier = @event.ticket_tiers.find_by!(name: name)

  FactoryBot.create(
    :ticket,
    user: @organizer,
    ticket_tier: tier
  )
end

Then("a sold-ticket deletion error should be shown") do
  expect(page).to have_content(
    "Cannot delete a ticket tier that has sold tickets."
  )
end
