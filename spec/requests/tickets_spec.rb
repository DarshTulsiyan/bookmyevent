require "rails_helper"

RSpec.describe "Single-tier ticket booking", type: :request do
  let(:attendee) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, status: :approved) }
  let(:tier) { FactoryBot.create(:ticket_tier, event: event, capacity: 3) }

  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  it "books one ticket for the selected tier" do
    log_in(attendee)

    expect {
      post tickets_path, params: { ticket_tier_id: tier.id }
    }.to change(Booking, :count).by(1).and change(Ticket, :count).by(1)

    expect(response).to redirect_to(my_tickets_path)
    expect(Booking.last.user).to eq(attendee)
    expect(Booking.last.tickets.first.ticket_tier).to eq(tier)
    expect(tier.reload.tickets_sold).to eq(1)
  end

  it "requires an attendee to book a tier" do
    post tickets_path, params: { ticket_tier_id: tier.id }

    expect(response).to redirect_to(login_path)
    expect(Booking.count).to eq(0)
  end
end
