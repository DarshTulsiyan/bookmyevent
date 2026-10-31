
require "rails_helper"

RSpec.describe TicketTier, type: :model do
  let(:organizer) { FactoryBot.create(:user, :organizer) }
  let(:event) do
    FactoryBot.create(
      :event,
      organizer: organizer,
      total_capacity: 100
    )
  end

  describe "validations" do
    it "requires a name" do
      tier = FactoryBot.build(:ticket_tier, event: event, name: nil)

      expect(tier).not_to be_valid
      expect(tier.errors[:name]).to include("can't be blank")
    end

    it "requires a unique name within the same event" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 40
      )

      duplicate = FactoryBot.build(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 30
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "allows the same name for different events" do
      another_event = FactoryBot.create(
        :event,
        organizer: organizer,
        total_capacity: 100
      )

      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 40
      )

      tier = FactoryBot.build(
        :ticket_tier,
        event: another_event,
        name: "General",
        capacity: 40
      )

      expect(tier).to be_valid
    end

    it "requires capacity to be a positive integer" do
      [0, -1, 1.5].each do |capacity|
        tier = FactoryBot.build(
          :ticket_tier,
          event: event,
          capacity: capacity
        )

        expect(tier).not_to be_valid
      end
    end

    it "does not allow total tier capacity to exceed event capacity" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 60
      )

      extra_tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        name: "VIP",
        capacity: 41
      )

      expect(extra_tier).not_to be_valid
      expect(extra_tier.errors[:capacity]).to include(
        "exceeds the event's total capacity"
      )
    end

    it "does not allow capacity below tickets already sold" do
      tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        capacity: 10,
        tickets_sold: 5
      )

      tier.capacity = 4

      expect(tier).not_to be_valid
      expect(tier.errors[:capacity]).to include(
        "cannot be less than tickets already sold"
      )
    end
    it "requires tickets_sold to be nonnegative" do
      tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        capacity: 10,
        tickets_sold: -1
      )

      expect(tier).not_to be_valid
      expect(tier.errors[:tickets_sold]).to include(
        "must be greater than or equal to 0"
      )
    end

    it "allows capacity to equal tickets already sold" do
      tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        capacity: 10,
        tickets_sold: 10
      )

      expect(tier).to be_valid
    end

    it "allows ticket tiers to use the exact remaining event capacity" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 60
      )

      tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        name: "VIP",
        capacity: 40
      )

      expect(tier).to be_valid
    end
  end
  describe "capacity methods" do
    it "calculates seats left" do
      tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        capacity: 10,
        tickets_sold: 3
      )

      expect(tier.seats_left).to eq(7)
    end

    it "identifies a sold-out tier" do
      tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        capacity: 10,
        tickets_sold: 10
      )

      expect(tier.sold_out?).to be true
    end

    it "identifies a tier that is not sold out" do
      tier = FactoryBot.build(
        :ticket_tier,
        event: event,
        capacity: 10,
        tickets_sold: 9
      )

      expect(tier.sold_out?).to be false
    end
  end
end
