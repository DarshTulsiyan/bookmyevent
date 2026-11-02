require "rails_helper"

RSpec.describe "Sold-out tickets", type: :request do
  let(:attendee) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, status: :approved) }

  let!(:general) do
    FactoryBot.create(
      :ticket_tier,
      event: event,
      name: "General",
      capacity: 2
    )
  end

  def log_in
    post login_path, params: {
      email: attendee.email,
      password: "Password123!"
    }
  end

  def sell_out_general
    Booking.place!(
      user: FactoryBot.create(:user),
      event: event,
      tickets_by_tier: { general.id => general.capacity }
    )
  end

  def page_html
    Nokogiri::HTML(response.body)
  end

  it "shows Sold Out to visitors" do
    sell_out_general

    get event_path(event)

    expect(response).to have_http_status(:ok)
    row = page_html.css("tbody tr").find do |element|
      element.at_css("td").text == "General"
    end
    expect(row.text).to include("Sold Out")
  end

  it "removes booking controls when all tiers are full" do
    sell_out_general
    log_in

    get event_path(event)

    expect(response).to have_http_status(:ok)
    expect(page_html.css("#quantity_#{general.id}")).to be_empty
    expect(
      page_html.css('input[type="submit"][value="Book tickets"]')
    ).to be_empty
    expect(response.body).to include("Sold Out")
  end

  it "keeps available tiers bookable when another tier is full" do
    vip = FactoryBot.create(
      :ticket_tier,
      event: event,
      name: "VIP",
      capacity: 2
    )
    sell_out_general
    log_in

    get event_path(event)

    expect(page_html.css("#quantity_#{general.id}")).to be_empty
    expect(page_html.at_css("#quantity_#{vip.id}")).to be_present
    expect(
      page_html.at_css('input[type="submit"][value="Book tickets"]')
    ).to be_present

    expect {
      post bookings_path, params: {
        event_id: event.id,
        tickets_by_tier: { vip.id.to_s => "1" }
      }
    }.to change(Ticket, :count).by(1)

    expect(response).to redirect_to(my_tickets_path)
    expect(vip.reload.tickets_sold).to eq(1)
  end

  it "rejects a stale selection without creating a partial booking" do
    vip = FactoryBot.create(
      :ticket_tier,
      event: event,
      name: "VIP",
      capacity: 2
    )
    log_in
    get event_path(event)

    # Another attendee takes the remaining seats after this page loads.
    sell_out_general

    expect {
      post bookings_path, params: {
        event_id: event.id,
        tickets_by_tier: {
          general.id.to_s => "1",
          vip.id.to_s => "1"
        }
      }
    }.to change(Booking, :count).by(0)
      .and change(Ticket, :count).by(0)

    expect(response).to redirect_to(event_path(event))
    expect(flash[:alert]).to eq("General: Sold Out")
    expect(attendee.bookings.count).to eq(0)
    expect(general.reload.tickets_sold).to eq(2)
    expect(vip.reload.tickets_sold).to eq(0)

    follow_redirect!

    expect(
      page_html.at_css('.flash-alert[role="alert"]').text
    ).to eq("General: Sold Out")
    expect(page_html.css("#quantity_#{general.id}")).to be_empty
  end
end