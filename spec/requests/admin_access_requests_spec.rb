require "rails_helper"

RSpec.describe "Admin access requests", type: :request do
  let(:reviewer) { FactoryBot.create(:user, role: :admin, admin_access_request_reviewer: true) }
  let(:attributes) do
    {
      name: "New Administrator",
      email: "new-admin@example.com",
      reason: "I coordinate events and need to review submissions.",
      password: "Password123!",
      password_confirmation: "Password123!"
    }
  end

  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  it "allows visitors to submit a request with a previously unused email" do
    get new_access_application_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Request admin access", "not already belong to an account")

    expect {
      post access_applications_path, params: { admin_access_request: attributes }
    }.to change(AdminAccessRequest, :count).by(1)

    request = AdminAccessRequest.last
    expect(request).to be_pending
    expect(response).to redirect_to(login_path)
    expect(User.find_by(email: request.email)).to be_nil
  end

  it "rejects an email already associated with any account role" do
    existing_user = FactoryBot.create(:user, :organizer, email: attributes[:email])

    expect {
      post access_applications_path,
           params: { admin_access_request: attributes }
    }.not_to change(AdminAccessRequest, :count)

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Email is already registered")
    expect(existing_user).to be_organizer
  end

  it "requires the designated seeded admin to review requests" do
    request = FactoryBot.create(:admin_access_request)
    get admin_access_requests_path
    expect(response).to redirect_to(login_path)

    log_in(FactoryBot.create(:user, role: :admin))
    get admin_access_requests_path
    expect(response).to redirect_to(root_path)
    patch approve_admin_access_request_path(request)
    expect(response).to redirect_to(root_path)
    expect(request.reload).to be_pending

    log_in(reviewer)
    get admin_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Admin access requests")
    get admin_access_requests_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(request.email, "Pending requests")
  end

  it "approves a request, creates an admin login, and records the reviewer" do
    request = FactoryBot.create(:admin_access_request, email: attributes[:email])
    log_in(reviewer)

    patch approve_admin_access_request_path(request),
          params: { reviewer_note: "Approved after verification.", role: "attendee" }

    user = User.find_by!(email: request.email)
    expect(user).to be_admin
    expect(user.can_review_admin_access_requests?).to be(false)
    expect(user.authenticate("Password123!")).to eq(user)
    expect(request.reload).to have_attributes(
      status: "approved",
      reviewed_by: reviewer,
      reviewer_note: "Approved after verification."
    )
    expect(response).to redirect_to(admin_access_requests_path)

    post logout_path
    post login_path, params: { email: user.email, password: "Password123!" }
    get admin_path
    expect(response).to have_http_status(:ok)
  end

  it "rejects a request without creating an account" do
    request = FactoryBot.create(:admin_access_request)
    log_in(reviewer)

    patch reject_admin_access_request_path(request), params: { reviewer_note: "Please reapply with more detail." }

    expect(request.reload).to have_attributes(status: "rejected", reviewed_by: reviewer)
    expect(request.reviewer_note).to eq("Please reapply with more detail.")
    expect(request.password_digest).to be_nil
    expect(User.find_by(email: request.email)).to be_nil
    expect(response).to redirect_to(admin_access_requests_path)
  end

  it "keeps the request pending if its email is registered before approval" do
    request = FactoryBot.create(:admin_access_request)
    FactoryBot.create(:user, email: request.email)
    log_in(reviewer)

    patch approve_admin_access_request_path(request)

    expect(response).to redirect_to(admin_access_request_path(request))
    expect(flash[:alert]).to include("already registered")
    expect(request.reload).to be_pending
  end

  it "shows reviewed requests and returns not found for unknown request ids" do
    request = FactoryBot.create(:admin_access_request)
    request.reject_by!(reviewer: reviewer)
    log_in(reviewer)

    get admin_access_requests_path
    expect(response.body).to include(request.email, "Rejected")

    get admin_access_request_path(id: "missing")
    expect(response).to have_http_status(:not_found)
  end

  it "shows a decision error when a request is submitted for rejection twice" do
    request = FactoryBot.create(:admin_access_request)
    request.reject_by!(reviewer: reviewer)
    log_in(reviewer)

    patch reject_admin_access_request_path(request)

    expect(response).to redirect_to(admin_access_request_path(request))
    expect(flash[:alert]).to include("Only pending requests can be reviewed")
  end
end
