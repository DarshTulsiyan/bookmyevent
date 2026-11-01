require "rails_helper"

RSpec.describe Event, type: :model do
  it "accepts valid event details" do
    expect(FactoryBot.build(:event)).to be_valid
  end

  it "requires an organizer" do
    expect(FactoryBot.build(:event, organizer: nil)).not_to be_valid
  end

  it "requires a title" do
    expect(FactoryBot.build(:event, title: "")).not_to be_valid
  end

  it "requires a venue" do
    expect(FactoryBot.build(:event, venue: "")).not_to be_valid
  end

  it "requires a start time" do
    expect(FactoryBot.build(:event, starts_at: nil)).not_to be_valid
  end

  it "requires a total capacity" do
    expect(FactoryBot.build(:event, total_capacity: nil)).not_to be_valid
  end

  it "requires a total capacity greater than zero" do
    expect(FactoryBot.build(:event, total_capacity: 0)).not_to be_valid
    expect(FactoryBot.build(:event, total_capacity: -5)).not_to be_valid
  end

  it "requires a whole-number total capacity" do
    expect(FactoryBot.build(:event, total_capacity: 2.5)).not_to be_valid
  end

  it "is pending when created" do
    expect(Event.new).to be_pending
  end

  it "rejects a start time in the past" do
    event = FactoryBot.build(:event, starts_at: 1.day.ago)

    expect(event).not_to be_valid
    expect(event.errors[:starts_at]).to include("must be in the future")
  end

  it "allows editing other details after the event has started" do
    event = FactoryBot.create(:event)
    event.update_column(:starts_at, 1.day.ago)

    expect(event.update(title: "Renamed")).to be(true)
  end

  it "rejects an unknown status" do
    expect(FactoryBot.build(:event, status: "archived")).not_to be_valid
  end

  describe "ticket tier capacity validation" do
    let(:organizer) { FactoryBot.create(:user, :organizer) }

    let(:event) do
      FactoryBot.create(
        :event,
        organizer: organizer,
        total_capacity: 100
      )
    end

    it "allows combined tier capacity equal to event capacity" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 60
      )

      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "VIP",
        capacity: 40
      )

      expect(event.reload).to be_valid
    end

    it "rejects combined tier capacity exceeding event capacity" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 60
      )

      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "VIP",
        capacity: 40
      )

      event.total_capacity = 99

      expect(event).not_to be_valid
      expect(event.errors[:total_capacity]).to include(
        "cannot be less than the combined ticket tier capacities"
      )
    end
  end

  describe "#seats_left" do
    let(:organizer) { FactoryBot.create(:user, :organizer) }

    let(:event) do
      FactoryBot.create(
        :event,
        organizer: organizer,
        total_capacity: 100
      )
    end

    it "returns the total remaining seats across all ticket tiers" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 60,
        tickets_sold: 20
      )

      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "VIP",
        capacity: 40,
        tickets_sold: 10
      )

      expect(event.seats_left).to eq(70)
    end

    it "returns zero when no seats remain" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 100,
        tickets_sold: 100
      )

      expect(event.seats_left).to eq(0)
    end

    it "returns zero when the event has no ticket tiers" do
      expect(event.seats_left).to eq(0)
    end
  end
end
