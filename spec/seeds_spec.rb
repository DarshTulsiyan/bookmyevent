require "rails_helper"

RSpec.describe "Development seeds", type: :model do
  it "creates the local sudo account idempotently" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))

    expect { load Rails.root.join("db/seeds.rb") }.to change(User, :count).by(2)
    expect { load Rails.root.join("db/seeds.rb") }.not_to change(User, :count)

    sudo_user = User.find_by!(email: "sudo_user@bookmyevent.com")
    expect(sudo_user).to be_sudo
    expect(sudo_user.authenticate("sudo@123")).to eq(sudo_user)
    expect(sudo_user.can_access_role_view?(:admin)).to be(true)
    expect(sudo_user.can_access_role_view?(:attendee)).to be(true)
    expect(sudo_user.can_access_role_view?(:organizer)).to be(true)
  end

  it "does not convert an existing non-sudo account into the sudo account" do
    existing_user = FactoryBot.create(:user, email: "sudo_user@bookmyevent.com")
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))

    expect { load Rails.root.join("db/seeds.rb") }
      .to raise_error("The development sudo email already belongs to a non-sudo account")

    expect(existing_user.reload).to be_attendee
  end
end
