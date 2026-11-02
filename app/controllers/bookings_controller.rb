class BookingsController < ApplicationController
  before_action :attendee_only

  def create
    @event = Event.find_by(id: params[:event_id])
    return head :not_found unless @event

    booking = Booking.place!(
      user: current_user,
      event: @event,
      tickets_by_tier: selected_tickets_by_tier
    )

    redirect_to my_tickets_path,
                notice: "Booking ##{booking.id} confirmed. Your Ticket IDs are listed below.",
                status: :see_other
  rescue Booking::InvalidRequest, Booking::Unavailable => error
    redirect_to event_path(@event), alert: error.message, status: :see_other
  rescue ActiveRecord::RecordInvalid
    redirect_to event_path(@event),
                alert: "Booking could not be completed. Please try again.",
                status: :see_other
  end

  private

  def selected_tickets_by_tier
    tickets_by_tier = params[:tickets_by_tier]
    tickets_by_tier.each_pair.with_object({}) do |(id, quantity), selected|
      next if quantity == "0" || quantity == ""

      tier_id = Integer(id, 10)
      ticket_count = Integer(quantity, 10)
      selected[tier_id] = ticket_count
    end
  end
end
