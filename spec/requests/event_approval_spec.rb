require "rails_helper"

RSpec.describe "Event approval", type: :request do
  let(:admin) { FactoryBot.create(:user, role: :admin) }
  let(:event) { FactoryBot.create(:event, status: :pending) }

  def log_in(user)
    post login_path, params: {
      email: user.email,
      password: "Password123!"
    }
  end

  describe "admin decisions" do
    before { log_in(admin) }

    it "approves a pending event" do
      patch approve_event_path(event)

      expect(response).to redirect_to(admin_pending_events_path)
      expect(flash[:notice]).to eq("Event approved and published.")
      expect(event.reload).to be_approved
    end

    it "rejects a pending event" do
      patch reject_event_path(event)

      expect(response).to redirect_to(admin_pending_events_path)
      expect(flash[:notice]).to eq("Event rejected.")
      expect(event.reload).to be_rejected
    end

    %i[approved rejected].each do |initial_status|
      %i[approve reject].each do |action|
        it "does not #{action} an #{initial_status} event" do
          event.update!(status: initial_status)

          patch public_send("#{action}_event_path", event)

          expect(response).to redirect_to(admin_pending_events_path)
          expect(flash[:alert]).to include(
            "can only be changed while pending"
          )
          expect(event.reload.status).to eq(initial_status.to_s)
        end
      end
    end

    it "returns 404 when approving a missing event" do
      patch approve_event_path(id: 0)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when rejecting a missing event" do
      patch reject_event_path(id: 0)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "permissions" do
    %i[approve reject].each do |action|
      it "requires login to #{action} an event" do
        patch public_send("#{action}_event_path", event)

        expect(response).to redirect_to(login_path)
        expect(event.reload).to be_pending
      end

      %i[attendee organizer].each do |role|
        it "prevents an #{role} from attempting to #{action} an event" do
          user = FactoryBot.create(:user, role: role)
          # For organizers, also prove owning the event grants no approval rights.
          event.update!(organizer: user) if role == :organizer
          log_in(user)

          patch public_send("#{action}_event_path", event)

          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq("Not authorized")
          expect(event.reload).to be_pending
        end
      end
    end
  end
end