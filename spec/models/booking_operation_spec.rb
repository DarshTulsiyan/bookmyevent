require "rails_helper"

RSpec.describe Booking, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, status: :approved) }
  let(:general) { FactoryBot.create(:ticket_tier, event: event, capacity: 5) }
  let(:vip) { FactoryBot.create(:ticket_tier, event: event, capacity: 2) }

  def book(tickets_by_tier)
    Booking.place!(user: user, event: event, tickets_by_tier: tickets_by_tier)
  end

  it "creates one ticket per seat across multiple tiers" do
    booking = book(general.id => 3, vip.id => 2)

    expect(booking.user).to eq(user)
    expect(booking.tickets.group(:ticket_tier_id).count).to eq(general.id => 3, vip.id => 2)
    expect(general.reload.tickets_sold).to eq(3)
    expect(vip.reload.tickets_sold).to eq(2)
  end

  it "allows an intentional second booking for the same tier" do
    book(general.id => 1)
    book(general.id => 2)

    expect(user.bookings.count).to eq(2)
    expect(general.reload.tickets_sold).to eq(3)
  end

  it "declines the whole booking if one tier has insufficient capacity" do
    general
    vip

    expect {
      book(general.id => 2, vip.id => 3)
    }.to raise_error(Booking::Unavailable)

    expect(Booking.count).to eq(0)
    expect(Ticket.count).to eq(0)
    expect(general.reload.tickets_sold).to eq(0)
    expect(vip.reload.tickets_sold).to eq(0)
  end

  it "rejects a sold-out tier" do
    book(general.id => 5)

    expect { book(general.id => 1) }.to raise_error(Booking::Unavailable, /Sold Out/)
    expect(general.reload.tickets_sold).to eq(5)
    expect(Ticket.count).to eq(5)
  end

  it "rejects an empty selection" do
    expect { book({}) }.to raise_error(Booking::InvalidRequest)
  end

  it "rejects unapproved events" do
    event.update!(status: :pending)

    expect { book(general.id => 1) }.to raise_error(Booking::Unavailable, "Event not open")
  end

  it "rejects organizers and suspended accounts" do
    user.update!(role: :organizer)
    expect { book(general.id => 1) }.to raise_error(Booking::InvalidRequest)
    user.update!(role: :attendee, suspended: true)
    expect { book(general.id => 1) }.to raise_error(Booking::InvalidRequest)
  end

  it "rolls back tickets, booking, and earlier counters if a later ticket fails" do
    general
    vip
    allow_any_instance_of(Ticket).to receive(:save!).and_wrap_original do |method, *args, **kwargs|
      raise ActiveRecord::RecordInvalid, method.receiver if method.receiver.ticket_tier_id == vip.id

      method.call(*args, **kwargs)
    end

    expect {
      book(general.id => 2, vip.id => 1)
    }.to raise_error(ActiveRecord::RecordInvalid)

    expect(Booking.count).to eq(0)
    expect(Ticket.count).to eq(0)
    expect(general.reload.tickets_sold).to eq(0)
    expect(vip.reload.tickets_sold).to eq(0)
  end
end
