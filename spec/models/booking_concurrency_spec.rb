require "rails_helper"
require "timeout"

RSpec.describe "Concurrent bookings", type: :model do
  self.use_transactional_tests = false

  before do
    @event = FactoryBot.create(:event, status: :approved)
    @users = FactoryBot.create_list(:user, 5)
    @tier = FactoryBot.create(:ticket_tier, event: @event, capacity: 1)
  end

  after do
    booking_ids = Booking.where(event: @event).pluck(:id)
    Ticket.where(booking_id: booking_ids).delete_all
    Booking.where(id: booking_ids).delete_all
    TicketTier.where(event: @event).delete_all
    @event.destroy!
    User.where(id: @users.map(&:id) + [ @event.organizer_id ]).delete_all
  end

  def compete(requests)
    ready = Queue.new
    start = Queue.new
    threads = requests.each_with_index.map do |tickets_by_tier, index|
      Thread.new do
        ready << true
        start.pop
        ActiveRecord::Base.connection_pool.with_connection do
          Booking.place!(user: @users[index], event: Event.find(@event.id), tickets_by_tier: tickets_by_tier)
          :success
        rescue Booking::Unavailable
          :unavailable
        end
      end
    end

    Timeout.timeout(15) do
      threads.size.times { ready.pop }
      threads.size.times { start << true }
      threads.map(&:value)
    end
  ensure
    threads&.each { |thread| thread.kill if thread.alive? }
    threads&.each(&:join)
  end

  it "gives the last seat to exactly one of five competing users" do
    results = compete(Array.new(5) { { @tier.id => 1 } })

    expect(results.count(:success)).to eq(1)
    expect(results.count(:unavailable)).to eq(4)
    expect(Booking.where(event: @event).count).to eq(1)
    expect(@tier.tickets.count).to eq(1)
    expect(@tier.reload.tickets_sold).to eq(1)
  end

  it "handles opposite tier order without partial bookings or deadlocks" do
    second = FactoryBot.create(:ticket_tier, event: @event, capacity: 1)
    results = compete([
      { @tier.id => 1, second.id => 1 },
      { second.id => 1, @tier.id => 1 }
    ])

    expect(results).to contain_exactly(:success, :unavailable)
    expect(Booking.where(event: @event).count).to eq(1)
    expect(@tier.reload.tickets_sold).to eq(1)
    expect(second.reload.tickets_sold).to eq(1)
    expect(Ticket.where(ticket_tier_id: [ @tier.id, second.id ]).count).to eq(2)
  end
end
