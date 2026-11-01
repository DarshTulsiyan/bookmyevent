require "rails_helper"

RSpec.describe Booking, type: :model do
  it "requires a user" do
    expect(FactoryBot.build(:booking, user: nil)).not_to be_valid
  end

  it "requires an event" do
    expect(FactoryBot.build(:booking, event: nil)).not_to be_valid
  end

  it "allows a user to make multiple bookings for the same event" do
    booking = FactoryBot.create(:booking)

    another_booking = FactoryBot.create(
      :booking,
      user: booking.user,
      event: booking.event
    )

    expect(another_booking.id).not_to eq(booking.id)
  end

  it "groups tickets from multiple tiers of the same event" do
    booking = FactoryBot.create(:booking)
    general = FactoryBot.create(:ticket_tier, event: booking.event)
    vip = FactoryBot.create(:ticket_tier, event: booking.event)
    first = FactoryBot.create(:ticket, booking: booking, ticket_tier: general)
    second = FactoryBot.create(:ticket, booking: booking, ticket_tier: vip)

    expect(booking.tickets).to contain_exactly(first, second)
    expect(booking.user.tickets).to contain_exactly(first, second)
  end

  it "does not delete a booking that has tickets" do
    ticket = FactoryBot.create(:ticket)

    expect(ticket.booking.destroy).to be false
    expect(Ticket.exists?(ticket.id)).to be true
  end
end
