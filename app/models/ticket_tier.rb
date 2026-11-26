class TicketTier < ApplicationRecord
  belongs_to :event
  has_many :tickets, dependent: :restrict_with_error

  validates :price_cents,
          numericality: {
            only_integer: true,
            greater_than_or_equal_to: 0,
            less_than_or_equal_to: 2_147_483_647
          }

  validate :price_has_valid_format

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

  def price
    return @price_input if defined?(@price_input)
    return if price_cents.nil?

    (BigDecimal(price_cents.to_s) / 100).to_s("F")
  end

  def price=(value)
    @price_input = value.to_s.strip

    if valid_price_input?
      self.price_cents = (BigDecimal(@price_input) * 100).to_i
    end
  end

  private

  def valid_price_input?
    @price_input.match?(/\A[0-9]+(?:\.[0-9]{1,2})?\z/)
  end

  def price_has_valid_format
    return unless defined?(@price_input)
    return if valid_price_input?

    errors.add(:price, "must be zero or positive with at most two decimal places")
  end

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
