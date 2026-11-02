class Ticket < ApplicationRecord
  belongs_to :booking
  belongs_to :ticket_tier

  has_one :user, through: :booking

  validate :ticket_tier_belongs_to_booking_event

  def ticket_code
    format("#%05d", id)
  end

  private

  def ticket_tier_belongs_to_booking_event
    return unless booking && ticket_tier
    return if booking.event_id == ticket_tier.event_id

    errors.add(:ticket_tier, "must belong to the booking's event")
  end
end
