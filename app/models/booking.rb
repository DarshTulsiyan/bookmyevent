class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :event

  has_many :tickets, dependent: :restrict_with_error
end
