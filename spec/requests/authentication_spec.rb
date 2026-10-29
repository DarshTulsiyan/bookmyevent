require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:signup_attributes) do
    {
      name: "Darsh",
      email: "darsh@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "attendee"
    }
  end

  it "registers a user and logs them in" do
    expect {
      post signup_path, params: { user: signup_attributes }
    }.to change(User, :count).by(1)

    expect(response).to redirect_to(root_path)

    get account_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("darsh@example.com")
  end

  it "allows organizer registration" do
    post signup_path, params: {
      user: signup_attributes.merge(role: "organizer")
    }

    expect(User.find_by!(email: "darsh@example.com")).to be_organizer
  end

  it "shows errors for invalid registration" do
    expect {
      post signup_path, params: {
        user: signup_attributes.merge(name: "")
      }
    }.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Name can&#39;t be blank")
  end

  it "prevents admin registration" do
    expect {
      post signup_path, params: {
        user: signup_attributes.merge(role: "admin")
      }
    }.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "logs in with the correct credentials" do
    user = FactoryBot.create(:user)

    post login_path, params: {
      email: "  #{user.email.upcase} ",
      password: "Password123!"
    }

    expect(response).to redirect_to(root_path)

    get account_path
    expect(response).to have_http_status(:ok)
  end

  it "rejects the wrong password" do
    user = FactoryBot.create(:user)

    post login_path, params: {
      email: user.email,
      password: "WrongPassword"
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Invalid email or password")

    get account_path
    expect(response).to redirect_to(login_path)
  end

  it "rejects suspended accounts" do
    user = FactoryBot.create(:user, suspended: true)

    post login_path, params: {
      email: user.email,
      password: "Password123!"
    }

    expect(response).to have_http_status(:unprocessable_entity)

    get account_path
    expect(response).to redirect_to(login_path)
  end

  it "logs out the user" do
    user = FactoryBot.create(:user)

    post login_path, params: {
      email: user.email,
      password: "Password123!"
    }

    delete logout_path

    expect(response).to redirect_to(root_path)

    get account_path
    expect(response).to redirect_to(login_path)
  end

  it "protects the account page" do
    get account_path

    expect(response).to redirect_to(login_path)
  end
end
