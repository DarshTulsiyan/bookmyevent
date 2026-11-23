require "rails_helper"

RSpec.describe EventRecommender do
  def available_event(title:, description: "", **attributes)
    event = FactoryBot.create(
      :event,
      title: title,
      description: description,
      status: :approved,
      **attributes
    )
    FactoryBot.create(:ticket_tier, event: event)
    event
  end

  let!(:source) do
    available_event(
      title: "Python Workshop",
      description: "Learn Python programming"
    )
  end

  it "ranks related content above a weaker match" do
    related = available_event(
      title: "Python Programming",
      description: "Learn Python"
    )
    weaker = available_event(
      title: "Painting Workshop",
      description: "Watercolor techniques"
    )

    expect(described_class.new(source).call).to eq([ related, weaker ])
  end

  it "excludes the source and events with no shared terms" do
    available_event(title: "Basketball Tournament", description: "Competitive sports")

    expect(described_class.new(source).call).to be_empty
  end

  it "excludes private, past, and sold-out events" do
    %i[draft pending rejected].each do |status|
      available_event(title: "Python Workshop", status: status)
    end

    past = available_event(title: "Python Workshop")
    past.update_columns(starts_at: 1.day.ago)

    sold_out = available_event(title: "Python Workshop")
    tier = sold_out.ticket_tiers.first
    tier.update!(tickets_sold: tier.capacity)

    expect(described_class.new(source).call).to be_empty
  end

  it "excludes events without ticket tiers" do
    FactoryBot.create(:event, title: "Python Workshop", status: :approved)

    expect(described_class.new(source).call).to be_empty
  end

  it "returns nothing for an unpublished source event" do
    source.update!(status: :pending)
    available_event(title: "Python Workshop")

    expect(described_class.new(source).call).to be_empty
  end

  it "limits the number of recommendations" do
    5.times { available_event(title: "Python Workshop") }

    expect(described_class.new(source).call(limit: 3).size).to eq(3)
  end

  it "handles text containing only stop words" do
    source.update!(title: "The", description: "and the")
    available_event(title: "Python Workshop")

    expect(described_class.new(source).call).to be_empty
  end

  it "breaks identical similarity scores by date, then ID" do
    later = available_event(title: "Python Workshop", starts_at: 5.days.from_now)
    first = available_event(title: "Python Workshop", starts_at: 2.days.from_now)
    second = available_event(title: "Python Workshop", starts_at: first.starts_at)

    expect(described_class.new(source).call).to eq([ first, second, later ])
  end
end
