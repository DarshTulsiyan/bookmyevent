require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  it "uses the shared sender and mailer layout" do
    expect(described_class.default[:from]).to eq("from@example.com")
    expect(described_class._layout).to eq("mailer")
  end
end
