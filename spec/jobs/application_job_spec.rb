require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  it "uses Active Job as its base class" do
    expect(described_class.superclass).to eq(ActiveJob::Base)
  end
end
