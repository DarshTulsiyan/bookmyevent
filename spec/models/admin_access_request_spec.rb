require "rails_helper"

RSpec.describe AdminAccessRequest, type: :model do
  let(:reviewer) { FactoryBot.create(:user, role: :admin, admin_access_request_reviewer: true) }

  def build_request(**attributes)
    FactoryBot.build(
      :admin_access_request,
      { name: "Applicant", email: "new-admin@example.com", reason: "I manage event operations.",
        password: "Password123!", password_confirmation: "Password123!" }.merge(attributes)
    )
  end

  it "normalizes email and hashes the applicant's password" do
    request = build_request(email: "  NEW-ADMIN@EXAMPLE.COM  ")

    expect(request).to be_valid
    expect(request.email).to eq("new-admin@example.com")
    expect(request.password_digest).not_to eq("Password123!")
    expect(request.authenticate("Password123!")).to eq(request)
  end

  it "rejects emails already registered for any role" do
    %i[attendee organizer admin].each do |role|
      user = FactoryBot.create(:user, role: role)
      request = build_request(email: user.email)

      expect(request).not_to be_valid
      expect(request.errors[:email]).to include("is already registered")
    end
  end

  it "validates required details, email format, password length, and confirmation" do
    expect(build_request(name: "")).not_to be_valid
    expect(build_request(email: "")).not_to be_valid
    expect(build_request(email: "invalid")).not_to be_valid
    expect(build_request(reason: "")).not_to be_valid
    expect(build_request(reason: "r" * 1_001)).not_to be_valid
    expect(build_request(password: "short", password_confirmation: "short")).not_to be_valid
    expect(build_request(password_confirmation: "Different123!")).not_to be_valid
  end

  it "allows only one pending request for an email, while allowing resubmission after rejection" do
    first = FactoryBot.create(:admin_access_request)
    duplicate = build_request(email: first.email.upcase)

    expect(duplicate).not_to be_valid
    first.reject_by!(reviewer: reviewer)

    expect(build_request(email: first.email)).to be_valid
  end

  it "creates an admin account and records approval by the designated reviewer" do
    request = FactoryBot.create(:admin_access_request)

    user = request.approve_by!(reviewer: reviewer, reviewer_note: "Verified with the team.")

    expect(user).to have_attributes(name: request.name, email: request.email, role: "admin")
    expect(user.authenticate("Password123!")).to eq(user)
    expect(user.can_review_admin_access_requests?).to be(false)
    expect(request.reload).to have_attributes(
      status: "approved",
      reviewed_by: reviewer,
      reviewer_note: "Verified with the team."
    )
    expect(request.password_digest).to be_nil
    expect(request.reviewed_at).to be_present
  end

  it "does not approve a request if its email became registered meanwhile" do
    request = FactoryBot.create(:admin_access_request)
    FactoryBot.create(:user, email: request.email)

    expect { request.approve_by!(reviewer: reviewer) }
      .to raise_error(ActiveRecord::RecordInvalid, /already registered/)
    expect(request.reload).to be_pending
    expect(User.where(email: request.email).count).to eq(1)
  end

  it "rejects without creating a user and clears the stored password digest" do
    request = FactoryBot.create(:admin_access_request)

    request.reject_by!(reviewer: reviewer, reviewer_note: "Insufficient detail.")

    expect(request.reload).to have_attributes(
      status: "rejected",
      reviewed_by: reviewer,
      reviewer_note: "Insufficient detail.",
      password_digest: nil
    )
    expect(User.find_by(email: request.email)).to be_nil
    expect(request.reviewed_at).to be_present
  end

  it "prevents non-reviewers and repeat decisions" do
    request = FactoryBot.create(:admin_access_request)
    regular_admin = FactoryBot.create(:user, role: :admin)

    expect { request.approve_by!(reviewer: regular_admin) }
      .to raise_error(ActiveRecord::RecordInvalid, /designated administrator/)
    expect { request.approve_by!(reviewer: nil) }
      .to raise_error(ActiveRecord::RecordInvalid, /designated administrator/)
    request.reject_by!(reviewer: reviewer)
    expect { request.reject_by!(reviewer: reviewer) }
      .to raise_error(ActiveRecord::RecordInvalid, /Only pending requests/)
  end

  it "rejects an oversized reviewer note without deciding the request" do
    request = FactoryBot.create(:admin_access_request)

    expect {
      request.reject_by!(reviewer: reviewer, reviewer_note: "n" * 1_001)
    }.to raise_error(ActiveRecord::RecordInvalid, /Reviewer note is too long/)

    expect(request.reload).to be_pending
  end
end
