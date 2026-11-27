require "rails_helper"

RSpec.describe Ticket, type: :model do
  it "formats a ticket ID with at least five digits" do
    expect(Ticket.new(id: 42).ticket_code).to eq("#00042")
    expect(Ticket.new(id: 123456).ticket_code).to eq("#123456")
  end

  it "requires a booking" do
    expect(FactoryBot.build(:ticket, booking: nil)).not_to be_valid
  end

  it "requires a ticket tier" do
    booking = FactoryBot.create(:booking)
    ticket = FactoryBot.build(:ticket, booking: booking, ticket_tier: nil)

    expect(ticket).not_to be_valid
  end

  it "gets its owner through the booking" do
    ticket = FactoryBot.create(:ticket)

    expect(ticket.user).to eq(ticket.booking.user)
  end

  it "allows multiple tickets for the same tier in one booking" do
    first = FactoryBot.create(:ticket)
    second = FactoryBot.create(
      :ticket,
      booking: first.booking,
      ticket_tier: first.ticket_tier
    )

    expect(second.id).not_to eq(first.id)
    expect(first.ticket_tier.tickets).to contain_exactly(first, second)
  end

  it "allows the same user to book the same tier in separate bookings" do
    first = FactoryBot.create(:ticket)
    booking = FactoryBot.create(
      :booking,
      user: first.user,
      event: first.booking.event
    )
    second = FactoryBot.create(
      :ticket,
      booking: booking,
      ticket_tier: first.ticket_tier
    )

    expect(first.user.tickets).to contain_exactly(first, second)
  end

  it "rejects a tier from a different event" do
    ticket = FactoryBot.build(:ticket, booking: FactoryBot.create(:booking))

    expect(ticket).not_to be_valid
    expect(ticket.errors[:ticket_tier]).to include(
      "must belong to the booking's event"
    )
  end

  it "still prevents deleting a tier with tickets" do
    ticket = FactoryBot.create(:ticket)

    expect(ticket.ticket_tier.destroy).to be false
    expect(Ticket.exists?(ticket.id)).to be true
  end

  describe "QR token generation" do
    it "automatically generates a secure QR token" do
      ticket = FactoryBot.create(:ticket)

      expect(ticket.qr_token).to be_present
      expect(ticket.qr_token).to match(/\A[0-9a-f]{64}\z/)
    end

    it "generates a unique QR token for each ticket" do
      first = FactoryBot.create(:ticket)
      second = FactoryBot.create(:ticket)

      expect(first.qr_token).not_to eq(second.qr_token)
    end
    it "generates a QR code in SVG format" do
      ticket = FactoryBot.create(:ticket)

      expect(ticket.qr_code_svg).to include("<svg")
    end
  end

  describe "check-in" do
    it "is not checked in initially" do
      ticket = FactoryBot.create(:ticket)

      expect(ticket.checked_in?).to be false
      expect(ticket.checked_in_at).to be_nil
    end

    it "records the check-in timestamp" do
      ticket = FactoryBot.create(:ticket)

      expect { ticket.check_in! }
        .to change { ticket.reload.checked_in_at }.from(nil)

      expect(ticket.checked_in?).to be true
    end

    it "prevents duplicate check-ins" do
      ticket = FactoryBot.create(:ticket)
      ticket.check_in!
      original_timestamp = ticket.reload.checked_in_at

      expect(ticket.check_in!).to be false
      expect(ticket.reload.checked_in_at).to eq(original_timestamp)
    end
  end
end
