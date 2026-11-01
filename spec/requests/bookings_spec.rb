require "rails_helper"

RSpec.describe "Ticket booking", type: :request do
  let(:attendee) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, status: :approved) }
  let(:tier) { FactoryBot.create(:ticket_tier, event: event, capacity: 3) }

  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  def submit(tickets_by_tier = { tier.id.to_s => "2" })
    post bookings_path, params: { event_id: event.id, tickets_by_tier: tickets_by_tier }
  end

  it "requires login for booking and My Tickets" do
    submit
    expect(response).to redirect_to(login_path)
    get my_tickets_path
    expect(response).to redirect_to(login_path)
  end

  it "rejects organizers and admins" do
    [ :organizer, :admin ].each do |role|
      log_in(FactoryBot.create(:user, role: role))
      submit
      expect(response).to redirect_to(root_path)
      get my_tickets_path
      expect(response).to redirect_to(root_path)
    end
    expect(Booking.count).to eq(0)
  end

  it "books for the logged-in user and shows each ticket code" do
    log_in(attendee)
    submit

    expect(response).to redirect_to(my_tickets_path)
    expect(Booking.last.user).to eq(attendee)
    expect(tier.reload.tickets_sold).to eq(2)
    follow_redirect!
    expect(response.body).to include("confirmed", event.title, tier.name)
    Booking.last.tickets.each do |ticket|
      expect(response.body).to include(ticket.ticket_code)
    end
  end

  it "shows only the current user's bookings" do
    own = Booking.place!(user: attendee, event: event, tickets_by_tier: { tier.id => 1 })
    other = Booking.place!(user: FactoryBot.create(:user), event: event, tickets_by_tier: { tier.id => 1 })
    log_in(attendee)
    get my_tickets_path

    expect(response.body).to include(own.tickets.first.ticket_code)
    expect(response.body).not_to include(other.tickets.first.ticket_code)
  end

  it "shows an empty state" do
    log_in(attendee)
    get my_tickets_path
    expect(response.body).to include("haven't booked any tickets yet")
  end

  it "returns an availability error without a partial booking" do
    log_in(attendee)
    get event_path(event)
    Booking.place!(user: FactoryBot.create(:user), event: event, tickets_by_tier: { tier.id => 2 })
    submit({ tier.id.to_s => "2" })
    expect(response).to redirect_to(event_path(event))
    follow_redirect!
    expect(response.body).to include("Only 1 seats available")
    expect(attendee.bookings.count).to eq(0)
  end

  it "asks for a selection when all quantities are zero or blank" do
    log_in(attendee)
    [ "0", "" ].each do |quantity|
      submit({ tier.id.to_s => quantity })
      expect(response).to redirect_to(event_path(event))
      expect(flash[:alert]).to eq("Select at least one ticket tier")
    end
    expect(Booking.count).to eq(0)
  end

  it "does not show the booking form for an unapproved event" do
    event.update!(status: :pending)
    log_in(attendee)
    tier
    get event_path(event)
    expect(response.body).to include("Booking is not open for this event")
    expect(response.body).not_to include("Choose your tickets")
    expect(Booking.count).to eq(0)
  end

  it "logs out suspended users before booking" do
    log_in(attendee)
    attendee.update!(suspended: true)
    submit
    expect(response).to redirect_to(login_path)
    expect(Booking.count).to eq(0)
  end
end
