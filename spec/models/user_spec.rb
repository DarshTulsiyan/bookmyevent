require "rails_helper"

RSpec.describe User, type: :model do
  it "accepts valid user details" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  it "requires a name" do
    expect(FactoryBot.build(:user, name: "")).not_to be_valid
  end

  it "requires an email" do
    expect(FactoryBot.build(:user, email: "")).not_to be_valid
  end

  it "rejects an invalid email format" do
    expect(FactoryBot.build(:user, email: "invalid")).not_to be_valid
  end

  it "rejects duplicate emails regardless of case" do
    FactoryBot.create(:user, email: "test@example.com")

    user = FactoryBot.build(:user, email: "TEST@example.com")

    expect(user).not_to be_valid
  end

  it "requires a valid role" do
    expect(FactoryBot.build(:user, role: nil)).not_to be_valid
    expect(FactoryBot.build(:user, role: "invalid")).not_to be_valid
  end

  it "requires a password on creation" do
    user = FactoryBot.build(
      :user,
      password: nil,
      password_confirmation: nil
    )

    expect(user).not_to be_valid
  end

  it "rejects short passwords" do
    user = FactoryBot.build(
      :user,
      password: "short",
      password_confirmation: "short"
    )

    expect(user).not_to be_valid
  end

  it "rejects mismatched password confirmation" do
    user = FactoryBot.build(
      :user,
      password_confirmation: "Different123!"
    )

    expect(user).not_to be_valid
  end

  it "authenticates the correct password" do
    user = FactoryBot.create(:user)

    expect(user.authenticate("Password123!")).to eq(user)
  end

  it "rejects an incorrect password" do
    user = FactoryBot.create(:user)

    expect(user.authenticate("WrongPassword")).to be(false)
  end
end