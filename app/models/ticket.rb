class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :ticket_tier
end
