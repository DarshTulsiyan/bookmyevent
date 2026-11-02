class TicketsController < ApplicationController
  before_action :attendee_only

  def index
    @bookings = current_user.bookings
                            .includes(:event, tickets: :ticket_tier)
                            .order(created_at: :desc, id: :desc)
  end

  def create
    ticket_tier = TicketTier.includes(:event).find_by(id: params[:ticket_tier_id])
    return head :not_found unless ticket_tier

    booking = Booking.place!(
      user: current_user,
      event: ticket_tier.event,
      tickets_by_tier: { ticket_tier.id => 1 }
    )

    redirect_to my_tickets_path,
                notice: "Booking ##{booking.id} confirmed. Your Ticket IDs are listed below.",
                status: :see_other
  rescue Booking::InvalidRequest, Booking::Unavailable => error
    redirect_to event_path(ticket_tier.event), alert: error.message, status: :see_other
  rescue ActiveRecord::RecordInvalid
    redirect_to event_path(ticket_tier.event),
                alert: "Booking could not be completed. Please try again.",
                status: :see_other
  end
end
