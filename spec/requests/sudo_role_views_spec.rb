require "rails_helper"

RSpec.describe "Sudo role views", type: :request do
  let(:sudo_user) { FactoryBot.create(:user, :sudo, name: "BookMyEvent Superuser") }

  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  it "exposes attendee, organizer, and admin workspaces to the sudo account" do
    event = FactoryBot.create(:event, organizer: sudo_user, title: "Sudo-Owned Event")
    log_in(sudo_user)

    get account_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(
      "Role workspaces",
      "Admin workspace",
      "Organizer workspace",
      "Attendee workspace",
      event.title
    )
    expect(response.body).to include("role-pill--sudo")

    get admin_path
    expect(response).to have_http_status(:ok)

    get my_tickets_path
    expect(response).to have_http_status(:ok)

    get new_event_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Create an event")
  end

  it "keeps organizer event editing scoped to events owned by the sudo account" do
    event = FactoryBot.create(:event)
    log_in(sudo_user)

    get edit_event_path(event)

    expect(response).to have_http_status(:not_found)
  end

  it "shows admin review controls for non-public events" do
    event = FactoryBot.create(:event, status: :pending)
    log_in(sudo_user)

    get event_path(event)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Pending Review", "Approve &amp; publish", "Reject")
  end

  it "allows the sudo account to view an organizer authorization document" do
    event = FactoryBot.create(:event)
    event.authorization_document.attach(
      io: StringIO.new("%PDF-1.4"),
      filename: "venue-proof.pdf",
      content_type: "application/pdf"
    )
    log_in(sudo_user)

    get authorization_document_event_path(event)

    expect(response).to have_http_status(:ok)
    expect(response.headers["Cache-Control"]).to eq("private, no-store")
    expect(response.headers["Content-Type"]).to include("application/octet-stream")
  end
end
