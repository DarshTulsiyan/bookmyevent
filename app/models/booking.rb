class Booking < ApplicationRecord
  class InvalidRequest < StandardError; end
  class Unavailable < StandardError; end

  belongs_to :user
  belongs_to :event

  has_many :tickets, dependent: :restrict_with_error

  def self.place!(user:, event:, tickets_by_tier:)
    raise InvalidRequest, "Select at least one ticket tier" if tickets_by_tier.empty?
    if tickets_by_tier.values.any? { |quantity| quantity <= 0 }
      raise InvalidRequest, "Ticket quantities must be positive"
    end

    requested = tickets_by_tier
    raise InvalidRequest, "Not authorized" unless user&.persisted? && user.attendee? && !user.suspended?
    raise InvalidRequest, "Event not found" unless event&.persisted?

    transaction(requires_new: true) do
      raise Unavailable, "Event not open" unless event.reload.approved?

      tiers = event.ticket_tiers.where(id: requested.keys).order(:id).lock.to_a
      unless tiers.size == requested.size
        raise InvalidRequest, "Select ticket tiers belonging to this event"
      end

      tiers.each do |tier|
        next if requested.fetch(tier.id) <= tier.seats_left

        message = tier.sold_out? ? "Sold Out" : "Only #{tier.seats_left} seats available"
        raise Unavailable, "#{tier.name}: #{message}"
      end

      booking = create!(user: user, event: event)

      tiers.each do |tier|
        quantity = requested.fetch(tier.id)
        quantity.times { booking.tickets.create!(ticket_tier: tier) }
        tier.update!(tickets_sold: tier.tickets_sold + quantity)
      end

      booking
    end
  end
end
