class TicketsController < ApplicationController
  before_action :attendee_only

  def index
    @bookings = current_user.bookings
                            .includes(:event, tickets: :ticket_tier)
                            .order(created_at: :desc, id: :desc)
  end
end
