
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

  describe "pricing" do
      it "defaults to free" do
        tier = FactoryBot.create(:ticket_tier)

        expect(tier.reload.price_cents).to eq(0)
        expect(BigDecimal(tier.price)).to eq(0)
      end

      it "converts a dollar amount into cents" do
        tier = FactoryBot.create(:ticket_tier, price: "12.50")

        expect(tier.reload.price_cents).to eq(1250)
        expect(BigDecimal(tier.price)).to eq(BigDecimal("12.50"))
      end

      it "handles single-cent prices exactly" do
        tier = FactoryBot.create(:ticket_tier, price: "0.01")

        expect(tier.reload.price_cents).to eq(1)
      end

      it "allows changing a paid tier to free" do
        tier = FactoryBot.create(:ticket_tier, price: "12.50")

        expect(tier.update(price: "0")).to be(true)
        expect(tier.reload.price_cents).to eq(0)
      end

      it "rejects invalid price input without changing the stored price" do
        tier = FactoryBot.create(:ticket_tier, price: "12.50")

        [ "-1", "12.345", "abc", "", "NaN", "Infinity" ].each do |value|
          expect(tier.update(price: value)).to be(false)
          expect(tier.errors[:price]).to be_present
          expect(TicketTier.find(tier.id).price_cents).to eq(1250)
        end
      end

      it "rejects invalid stored cent amounts" do
        [ nil, -1, 1.5, 2_147_483_648 ].each do |value|
          tier = FactoryBot.build(:ticket_tier, price_cents: value)

          expect(tier).not_to be_valid
          expect(tier.errors[:price_cents]).to be_present
        end
      end
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
      [ 0, -1, 1.5 ].each do |capacity|
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
