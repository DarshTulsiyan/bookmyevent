require "rails_helper"

RSpec.describe "Booking and event validation edge cases" do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, status: :approved) }

  it "rejects zero and negative ticket quantities" do
    [ 0, -1 ].each do |quantity|
      expect {
        Booking.place!(user: user, event: event, tickets_by_tier: { 1 => quantity })
      }.to raise_error(Booking::InvalidRequest, "Ticket quantities must be positive")
    end
  end

  it "rejects missing users and events" do
    expect {
      Booking.place!(user: nil, event: event, tickets_by_tier: { 1 => 1 })
    }.to raise_error(Booking::InvalidRequest, "Not authorized")
    expect {
      Booking.place!(user: user, event: nil, tickets_by_tier: { 1 => 1 })
    }.to raise_error(Booking::InvalidRequest, "Event not found")
    expect {
      Booking.place!(user: user, event: Event.new, tickets_by_tier: { 1 => 1 })
    }.to raise_error(Booking::InvalidRequest, "Event not found")
  end

  it "rejects a tier from another event without creating a booking" do
    tier = FactoryBot.create(:ticket_tier)
    expect {
      Booking.place!(user: user, event: event, tickets_by_tier: { tier.id => 1 })
    }.to raise_error(Booking::InvalidRequest, "Select ticket tiers belonging to this event")
    expect(Booking.count).to eq(0)
  end

  it "does not replace proof or resubmit an approved event" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("%PDF-1.4"), filename: "permit.pdf"
    )
    expect(event.submit_for_review(blob)).to be(false)
    expect(event.reload).to be_approved
    expect(event.authorization_document).not_to be_attached
    expect(event.errors[:status]).to include("must be draft or rejected to submit for review")
  end

  it "reports missing event capacity without crashing" do
    event.total_capacity = nil
    expect(event).not_to be_valid
    expect(event.errors[:total_capacity]).not_to be_empty
  end

  it "reports missing tier associations and numeric fields without crashing" do
    tier = FactoryBot.build(:ticket_tier, event: nil)
    expect(tier).not_to be_valid
    expect(tier.errors[:event]).not_to be_empty

    tier = FactoryBot.build(:ticket_tier, event: event, capacity: nil, tickets_sold: nil)
    expect(tier).not_to be_valid
    expect(tier.errors[:capacity]).not_to be_empty
    expect(tier.errors[:tickets_sold]).not_to be_empty
  end

  it "validates tiers when their unsaved event has no capacity yet" do
    event.total_capacity = nil
    tier = FactoryBot.build(:ticket_tier, event: event)
    tier.valid?
    expect(tier.errors[:capacity]).to be_empty
  end
end
