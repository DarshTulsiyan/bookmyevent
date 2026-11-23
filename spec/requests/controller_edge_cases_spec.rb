require "rails_helper"

RSpec.describe "Controller edge cases", type: :request do
  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  it "returns 404 for a nonexistent event page" do
    get event_path(id: 0)
    expect(response).to have_http_status(:not_found)
  end

  it "returns 404 for nonexistent booking events and ticket tiers" do
    log_in(FactoryBot.create(:user))
    post bookings_path, params: { event_id: 0, tickets_by_tier: { "1" => "1" } }
    expect(response).to have_http_status(:not_found)
    post tickets_path, params: { ticket_tier_id: 0 }
    expect(response).to have_http_status(:not_found)
  end

  it "shows an organizer's account and their events" do
    organizer = FactoryBot.create(:user, role: :organizer)
    event = FactoryBot.create(:event, organizer: organizer)
    log_in(organizer)
    get account_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(event.title)
  end

  it "renders validation errors for an invalid event edit" do
    event = FactoryBot.create(:event)
    log_in(event.organizer)
    patch event_path(event), params: { event: { title: "" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(event.reload.title).not_to be_empty
  end

  it "requires proof to exist even for an authorized download" do
    event = FactoryBot.create(:event)
    log_in(event.organizer)
    get authorization_document_event_path(event)
    expect(response).to have_http_status(:not_found)
  end

  it "rejects resubmission of a pending event" do
    event = FactoryBot.create(:event, status: :pending)
    log_in(event.organizer)
    patch submit_for_review_event_path(event)
    expect(flash[:alert]).to include("Only draft or rejected")
    expect(event.reload).to be_pending
  end

  it "updates and deletes tiers using Turbo Stream responses" do
    event = FactoryBot.create(:event)
    tier = FactoryBot.create(:ticket_tier, event: event)
    log_in(event.organizer)
    headers = { "Accept" => "text/vnd.turbo-stream.html" }

    patch event_tier_path(event, tier_id: tier.id),
          params: { ticket_tier: { name: "Updated" } }, headers: headers
    expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    expect(tier.reload.name).to eq("Updated")

    delete event_tier_path(event, tier_id: tier.id), headers: headers
    expect(response).to have_http_status(:ok)
    expect(TicketTier.exists?(tier.id)).to be(false)
  end

  it "shows deletion errors when a tier callback refuses deletion" do
    event = FactoryBot.create(:event)
    tier = FactoryBot.create(:ticket_tier, event: event)
    allow_any_instance_of(TicketTier).to receive(:destroy) do |record|
      record.errors.add(:base, "Deletion blocked")
      false
    end
    log_in(event.organizer)
    delete event_tier_path(event, tier_id: tier.id)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Deletion blocked")
    expect(TicketTier.exists?(tier.id)).to be(true)
  end
end
