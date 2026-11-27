require "rails_helper"

RSpec.describe User, "role view access", type: :model do
  it "allows a sudo user to access all role views" do
    sudo_user = FactoryBot.build(:user, :sudo)

    expect(sudo_user.can_access_role_view?(:attendee)).to be(true)
    expect(sudo_user.can_access_role_view?(:organizer)).to be(true)
    expect(sudo_user.can_access_role_view?(:admin)).to be(true)
  end

  it "limits regular users to their own role view" do
    attendee = FactoryBot.build(:user)
    organizer = FactoryBot.build(:user, :organizer)
    admin = FactoryBot.build(:user, :admin)

    expect(attendee.can_access_role_view?(:attendee)).to be(true)
    expect(attendee.can_access_role_view?(:organizer)).to be(false)
    expect(organizer.can_access_role_view?(:organizer)).to be(true)
    expect(organizer.can_access_role_view?(:admin)).to be(false)
    expect(admin.can_access_role_view?(:admin)).to be(true)
    expect(admin.can_access_role_view?(:attendee)).to be(false)
  end

  it "denies unknown role views" do
    user = FactoryBot.build(:user, :attendee)

    expect(user.can_access_role_view?(:unknown)).to be(false)
    expect(user.can_access_role_view?(nil)).to be(false)
  end
end
