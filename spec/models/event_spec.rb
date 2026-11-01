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
end
