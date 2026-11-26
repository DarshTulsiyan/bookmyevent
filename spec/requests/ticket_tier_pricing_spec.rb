require "rails_helper"

RSpec.describe "Ticket tier pricing", type: :request do
  let(:organizer) { FactoryBot.create(:user, :organizer) }
  let(:event) { FactoryBot.create(:event, organizer: organizer) }

  def log_in(user)
    post login_path, params: {
      email: user.email,
      password: "Password123!"
    }
  end

  it "lets the owner create a priced tier" do
    log_in(organizer)

    expect {
      post event_tiers_path(event), params: {
        ticket_tier: {
          name: "General",
          capacity: 10,
          price: "12.50"
        }
      }
    }.to change(TicketTier, :count).by(1)

    expect(response).to redirect_to(edit_event_path(event))
    expect(event.ticket_tiers.last.price_cents).to eq(1250)
  end

  it "lets the owner update a price" do
    tier = FactoryBot.create(:ticket_tier, event: event)
    log_in(organizer)

    patch event_tier_path(event, tier), params: {
      ticket_tier: { price: "25.99" }
    }

    expect(response).to redirect_to(edit_event_path(event))
    expect(tier.reload.price_cents).to eq(2599)
  end

  it "rejects a price with more than two decimal places" do
    tier = FactoryBot.create(:ticket_tier, event: event, price: "10")
    log_in(organizer)

    patch event_tier_path(event, tier), params: {
      ticket_tier: { price: "10.999" }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(tier.reload.price_cents).to eq(1000)
    expect(response.body).to include(
      "must be zero or positive with at most two decimal places"
    )
  end

  it "prevents another organizer from changing the price" do
    tier = FactoryBot.create(:ticket_tier, event: event, price: "10")
    log_in(FactoryBot.create(:user, :organizer))

    patch event_tier_path(event, tier), params: {
      ticket_tier: { price: "1" }
    }

    expect(response).to redirect_to(root_path)
    expect(tier.reload.price_cents).to eq(1000)
  end

  it "prevents attendees from changing the price" do
    tier = FactoryBot.create(:ticket_tier, event: event, price: "10")
    log_in(FactoryBot.create(:user))

    patch event_tier_path(event, tier), params: {
      ticket_tier: { price: "1" }
    }

    expect(response).to redirect_to(root_path)
    expect(tier.reload.price_cents).to eq(1000)
  end

  it "shows paid and free tier prices to visitors" do
    event.update!(status: :approved)
    FactoryBot.create(
      :ticket_tier, event: event, name: "General", price: "12.50"
    )
    FactoryBot.create(
      :ticket_tier, event: event, name: "Community", price: "0"
    )

    get event_path(event)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("$12.50 USD", "Free")
  end
end