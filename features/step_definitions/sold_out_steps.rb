Given("another attendee books all VIP tickets") do
  Booking.place!(
    user: FactoryBot.create(:user),
    event: @concert,
    tickets_by_tier: { @vip.id => @vip.capacity }
  )
end

When("I open the concert ticket page") do
  visit event_path(@concert)
end

Then("General is sold out and VIP remains selectable") do
  expect(page).to have_content("General: Sold Out")
  expect(page).not_to have_field("General quantity")
  expect(page).to have_field("VIP quantity")
  expect(page).to have_button("Book tickets")
end

When("I book one VIP ticket") do
  fill_in "VIP quantity", with: 1
  click_button "Book tickets"
end

Then("my VIP booking is confirmed") do
  expect(page).to have_current_path(my_tickets_path)
  expect(page).to have_content("confirmed")
  expect(@attendee.tickets.count).to eq(1)
  expect(@attendee.tickets.first.ticket_tier).to eq(@vip)
end

Then("no concert tickets can be selected or booked") do
  expect(page).to have_content("Sold Out")
  expect(page).not_to have_field("General quantity")
  expect(page).not_to have_field("VIP quantity")
  expect(page).not_to have_button("Book tickets")
end
