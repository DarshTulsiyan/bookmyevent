require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  let(:admin) { FactoryBot.create(:user, role: :admin) }

  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  it "requires login for every admin page" do
    [ admin_path, admin_users_path, admin_pending_events_path, admin_published_events_path, admin_rejected_events_path ].each do |path|
      get path

      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("Please log in")
    end
  end

  it "denies access to signed-in non-admin users" do
    log_in(FactoryBot.create(:user))

    get admin_path

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq("Not authorized")
  end

  it "shows summary totals, role breakdown, and user list to admins" do
    FactoryBot.create(:event, title: "Awaiting Approval")
    FactoryBot.create(:event, title: "Published Concert", status: :approved)
    log_in(admin)

    get admin_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Admin dashboard")
    expect(response.body).to match(/<dt>Total users<\/dt>\s*<dd>#{User.count}<\/dd>/)
    expect(response.body).to match(/<dt>Total events<\/dt>\s*<dd>#{Event.count}<\/dd>/)
    expect(response.body).to include("Users by role", "Organizer", admin.email)
    expect(response.body).to include("Events awaiting approval", "Published events")
    expect(response.body).not_to include("Awaiting Approval", "Published Concert")
  end

  it "lists users with their roles and account status" do
    attendee = FactoryBot.create(:user, name: "Attendee One")
    suspended_organizer = FactoryBot.create(:user, :organizer, name: "Organizer One", suspended: true)
    log_in(admin)

    get admin_users_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(attendee.email, "Attendee", "Active")
    expect(response.body).to include(suspended_organizer.email, "Organizer", "Suspended")
  end

  it "shows pending, published, and rejected events on separate admin pages" do
    pending_event = FactoryBot.create(:event, title: "Awaiting Approval")
    published_event = FactoryBot.create(:event, title: "Published Concert", status: :approved)
    rejected_event = FactoryBot.create(:event, title: "Rejected Concert", status: :rejected)
    log_in(admin)

    get admin_pending_events_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Awaiting Approval")
    expect(response.body).not_to include("Published Concert")

    get admin_published_events_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Published Concert")
    expect(response.body).not_to include("Awaiting Approval", "Rejected Concert")

    get admin_rejected_events_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Rejected Concert")
    expect(response.body).not_to include("Awaiting Approval", "Published Concert")
  end
end
