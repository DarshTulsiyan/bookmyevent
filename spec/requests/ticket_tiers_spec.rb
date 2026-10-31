
require "rails_helper"

RSpec.describe "TicketTiers", type: :request do
  let(:organizer) { FactoryBot.create(:user, :organizer) }
  let(:attendee) { FactoryBot.create(:user) }
  let(:event) do
    FactoryBot.create(
      :event,
      organizer: organizer,
      total_capacity: 100
    )
  end

  def log_in(user)
    post login_path, params: {
      email: user.email,
      password: "Password123!"
    }
  end

  describe "POST /events/:event_id/tiers" do
    it "redirects unauthenticated users to login" do
      post event_tiers_path(event_id: event.id),
           params: { ticket_tier: { name: "General", capacity: 50 } }

      expect(response).to redirect_to(login_path)
    end

    it "denies attendees access" do
      log_in(attendee)

      post event_tiers_path(event_id: event.id),
           params: { ticket_tier: { name: "General", capacity: 50 } }

      expect(response).to redirect_to(root_path)
      expect(TicketTier.count).to eq(0)
    end

    it "denies organizers access to another organizer's event" do
      another_organizer = FactoryBot.create(:user, :organizer)
      another_event = FactoryBot.create(
        :event,
        organizer: another_organizer,
        total_capacity: 100
      )

      log_in(organizer)

      post event_tiers_path(event_id: another_event.id),
           params: { ticket_tier: { name: "General", capacity: 50 } }

      expect(response).to redirect_to(root_path)
      expect(TicketTier.count).to eq(0)
    end


it "creates a ticket tier when the organizer provides valid details" do
  log_in(organizer)

  expect {
    post event_tiers_path(event_id: event.id),
         params: {
           ticket_tier: {
             name: "General",
             capacity: 50
           }
         }
  }.to change(TicketTier, :count).by(1)

  tier = TicketTier.order(:id).last

  expect(tier.name).to eq("General")
  expect(tier.capacity).to eq(50)
  expect(tier.event_id).to eq(event.id)
  expect(response).to redirect_to(edit_event_path(event))
end



it "does not create a ticket tier that exceeds event capacity" do
  FactoryBot.create(
    :ticket_tier,
    event: event,
    name: "General",
    capacity: 80
  )

log_in(organizer)

expect {
  post event_tiers_path(event_id: event.id),
       params: {
         ticket_tier: {
           name: "VIP",
           capacity: 30
         }
       }
}.not_to change(TicketTier, :count)

expect(response).to have_http_status(:unprocessable_entity)
end
  end

  describe "PATCH /events/:event_id/tiers/:tier_id" do
    let(:tier) do
      FactoryBot.create(:ticket_tier, event: event)
    end

    it "denies attendees access" do
      log_in(attendee)

      patch event_tier_path(event_id: event.id, tier_id: tier.id),
            params: { ticket_tier: { name: "Updated", capacity: 20 } }

      expect(response).to redirect_to(root_path)
      expect(tier.reload.name).not_to eq("Updated")
    end

    it "denies an organizer access to another organizer's tier" do
      another_organizer = FactoryBot.create(:user, :organizer)
      another_event = FactoryBot.create(
        :event,
        organizer: another_organizer,
        total_capacity: 100
      )
      another_tier = FactoryBot.create(
        :ticket_tier,
        event: another_event
      )

      log_in(organizer)

      patch event_tier_path(
        event_id: another_event.id,
        tier_id: another_tier.id
      ), params: { ticket_tier: { name: "Updated", capacity: 20 } }

      expect(response).to redirect_to(root_path)
      expect(another_tier.reload.name).not_to eq("Updated")
    end
    it "updates a ticket tier when the organizer provides valid details" do
  log_in(organizer)
  tier

  patch event_tier_path(event_id: event.id, tier_id: tier.id),
        params: {
          ticket_tier: {
            name: "Premium",
            capacity: 80
          }
        }

  expect(response).to redirect_to(edit_event_path(event))
  expect(tier.reload.name).to eq("Premium")
  expect(tier.capacity).to eq(80)
end
    it "does not update a tier when its capacity exceeds event capacity" do
      FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 60
      )

      tier.update!(capacity: 40)

      log_in(organizer)

      patch event_tier_path(event_id: event.id, tier_id: tier.id),
            params: {
              ticket_tier: {
                name: "VIP",
                capacity: 50
              }
            }

      expect(response).to have_http_status(:unprocessable_content)
      expect(tier.reload.name).not_to eq("VIP")
      expect(tier.capacity).to eq(40)
      expect(response.body).to include(
        "Capacity exceeds the event&#39;s total capacity"
      )
    end
  end

  describe "DELETE /events/:event_id/tiers/:tier_id" do
    let(:tier) do
      FactoryBot.create(:ticket_tier, event: event)
    end

    it "denies attendees access" do
      log_in(attendee)

      delete event_tier_path(event_id: event.id, tier_id: tier.id)

      expect(response).to redirect_to(root_path)
      expect(TicketTier.exists?(tier.id)).to be true
    end

    it "denies an organizer access to another organizer's tier" do
      another_organizer = FactoryBot.create(:user, :organizer)
      another_event = FactoryBot.create(
        :event,
        organizer: another_organizer,
        total_capacity: 100
      )
      another_tier = FactoryBot.create(
        :ticket_tier,
        event: another_event
      )

      log_in(organizer)

      delete event_tier_path(
        event_id: another_event.id,
        tier_id: another_tier.id
      )

      expect(response).to redirect_to(root_path)
      expect(TicketTier.exists?(another_tier.id)).to be true
    end

    it "does not delete a ticket tier that has sold tickets" do
      sold_tier = FactoryBot.create(
        :ticket_tier,
        event: event,
        name: "General",
        capacity: 50
      )

      FactoryBot.create(
        :ticket,
        user: attendee,
        ticket_tier: sold_tier
      )

      log_in(organizer)

      expect {
        delete event_tier_path(
          event_id: event.id,
          tier_id: sold_tier.id
        )
      }.not_to change(TicketTier, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(sold_tier.reload).to be_persisted
      expect(response.body).to include(
        "Cannot delete a ticket tier that has sold tickets."
      )
    end

    it "deletes a ticket tier when it has no sold tickets" do
      log_in(organizer)
      tier

      expect {
        delete event_tier_path(event_id: event.id, tier_id: tier.id)
      }.to change(TicketTier, :count).by(-1)

      expect(response).to redirect_to(edit_event_path(event))
    end
  end
end