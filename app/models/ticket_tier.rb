class TicketTier < ApplicationRecord
  belongs_to :event

  def seats_left
    capacity - tickets_sold
  end
end
