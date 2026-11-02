class TicketTier < ApplicationRecord
  belongs_to :event
  has_many :tickets, dependent: :restrict_with_error

  validates :name,
            presence: true,
            uniqueness: { scope: :event_id }

  validates :capacity,
            numericality: { only_integer: true, greater_than: 0 }

  validates :tickets_sold,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validate :fits_in_event
  validate :not_below_sold

  def seats_left
    capacity.to_i - tickets_sold.to_i
  end

  def sold_out?
    seats_left == 0
  end

  private

  def fits_in_event
    return unless event && capacity.is_a?(Numeric)
    return if event.total_capacity.nil?

    other_tiers_capacity = event.ticket_tiers
                               .where.not(id: id)
                               .sum(:capacity)

    if other_tiers_capacity + capacity > event.total_capacity
      errors.add(:capacity, "exceeds the event's total capacity")
    end
  end

  def not_below_sold
    return if capacity.nil? || tickets_sold.nil?
    return if capacity >= tickets_sold

    errors.add(:capacity, "cannot be less than tickets already sold")
  end
end
