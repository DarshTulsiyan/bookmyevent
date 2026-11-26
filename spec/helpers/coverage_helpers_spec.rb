require "rails_helper"

RSpec.describe EventsHelper, type: :helper do
  it "summarizes a draft without allocated capacity" do
    event = FactoryBot.build(:event, status: :draft)

    expect(helper.tier_summary(event)).to include(allocation_percent: 0, allocated: 0)
  end

  it "distinguishes tickets not on sale, sold out, low availability, and on sale" do
    expect(helper.availability_chip(0, 0)).to include("Tickets soon")
    expect(helper.availability_chip(0, 10)).to include("Sold out")
    expect(helper.availability_chip(2, 10)).to include("Almost gone")
    expect(helper.availability_chip(8, 10)).to include("On sale")
  end

  it "labels an event that has already started" do
    event = FactoryBot.build(:event, starts_at: 1.minute.ago)
    expect(helper.relative_start(event)).to eq("Happening now")
  end
end

RSpec.describe ApplicationHelper, type: :helper do
  it "renders a navigation link without an optional icon" do
    allow(helper).to receive(:current_page?).and_return(false)
    expect(helper.nav_link("Events", events_path)).to include("Events")
    expect(helper.nav_link("Events", events_path)).not_to include("<svg")
  end
end
