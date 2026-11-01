require "rails_helper"

RSpec.describe "Events", type: :request do
  let(:organizer) { FactoryBot.create(:user, :organizer) }

  let(:event_attributes) do
    {
      title: "Spring Concert",
      description: "An evening of live music.",
      venue: "Rudder Auditorium",
      starts_at: 1.week.from_now.strftime("%Y-%m-%dT%H:%M"),
      total_capacity: 100
    }
  end

  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  it "creates a pending event owned by the current organizer" do
    log_in(organizer)
    other = FactoryBot.create(:user, :organizer)

    expect {
      post events_path, params: {
        event: event_attributes.merge(status: "approved", organizer_id: other.id)
      }
    }.to change(Event, :count).by(1)

    event = Event.last
    expect(event).to be_pending
    expect(event.organizer).to eq(organizer)
    expect(response).to redirect_to(edit_event_path(event))
  end

  it "shows errors for an invalid event" do
    log_in(organizer)

    expect {
      post events_path, params: { event: event_attributes.merge(title: "") }
    }.not_to change(Event, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Title can&#39;t be blank")
  end

  it "updates the organizer's own event without changing its status" do
    event = FactoryBot.create(:event, organizer: organizer)
    log_in(organizer)

    patch event_path(event), params: { event: { title: "Renamed", status: "approved" } }

    expect(response).to redirect_to(edit_event_path(event))
    expect(event.reload.title).to eq("Renamed")
    expect(event).to be_pending
  end

  it "returns 404 for another organizer's event" do
    event = FactoryBot.create(:event)
    log_in(organizer)

    get edit_event_path(event)
    expect(response).to have_http_status(:not_found)

    patch event_path(event), params: { event: { title: "Hijacked" } }
    expect(response).to have_http_status(:not_found)
    expect(event.reload.title).not_to eq("Hijacked")
  end

  it "turns away attendees" do
    log_in(FactoryBot.create(:user))

    get new_event_path

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq("Not authorized")
  end

  it "requires login" do
    get new_event_path

    expect(response).to redirect_to(login_path)
  end

  describe "browsing" do
    let!(:approved) { FactoryBot.create(:event, title: "Approved Show", status: :approved) }
    let!(:pending) { FactoryBot.create(:event, title: "Pending Show") }

    # Phase 2: admin approval. Pending events are listed until then.
    it "lists upcoming events, without login" do
      past = FactoryBot.create(:event, title: "Past Show", status: :approved)
      past.update_column(:starts_at, 1.day.ago)

      get events_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Approved Show", "Pending Show")
      expect(response.body).not_to include("Past Show")
    end

    it "shows an approved event with its tiers to an attendee" do
      FactoryBot.create(:ticket_tier, event: approved, name: "VIP", capacity: 10, tickets_sold: 4)
      log_in(FactoryBot.create(:user))

      get event_path(approved)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Approved Show", "VIP", "6")
    end

    # Phase 2: admin approval. Restore to expect :not_found.
    it "shows a pending event to attendees without the status badge" do
      log_in(FactoryBot.create(:user))

      get event_path(pending)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Pending approval")
    end

    it "shows a pending event to its organizer" do
      log_in(pending.organizer)

      get event_path(pending)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Pending approval")
    end
  end
end
