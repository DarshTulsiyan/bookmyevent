Given("an approved concert has General and VIP tickets") do
  @concert = FactoryBot.create(:event, status: :approved)
  @general = FactoryBot.create(:ticket_tier, event: @concert, name: "General", capacity: 3)
  @vip = FactoryBot.create(:ticket_tier, event: @concert, name: "VIP", capacity: 2)
end

When("I book 2 General tickets and 1 VIP ticket") do
  visit event_path(@concert)
  fill_in "General quantity", with: 2
  fill_in "VIP quantity", with: 1
  click_button "Book tickets"
end

Then("I should see my three tickets grouped under one booking") do
  expect(page).to have_current_path(my_tickets_path)
  expect(page).to have_content("confirmed")
  expect(@attendee.bookings.count).to eq(1)
  expect(@attendee.tickets.count).to eq(3)
  @attendee.tickets.each do |ticket|
    expect(page).to have_content(ticket.ticket_code)
  end
  click_link "Events", exact: true
  click_link "My Tickets"
  expect(page).to have_content(@concert.title)
end

Then("the concert should have sold 2 General tickets and 1 VIP ticket") do
  expect(@general.reload.tickets_sold).to eq(2)
  expect(@vip.reload.tickets_sold).to eq(1)
end

Given("I am choosing concert tickets") do
  visit event_path(@concert)
  fill_in "General quantity", with: 1
  fill_in "VIP quantity", with: 1
end

Given("another attendee books all General tickets") do
  Booking.place!(user: FactoryBot.create(:user), event: @concert, tickets_by_tier: { @general.id => 3 })
end

When("I submit my concert ticket selection") do
  click_button "Book tickets"
end

Then("I should see a sold-out booking error") do
  expect(page).to have_css(
    '.flash-alert[role="alert"]',
    text: "General: Sold Out"
  )
end

Then("I should have no bookings") do
  expect(@attendee.bookings.count).to eq(0)
  expect(@vip.reload.tickets_sold).to eq(0)
end
