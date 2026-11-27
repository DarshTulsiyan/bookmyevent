require "securerandom"
require "rqrcode"

class Ticket < ApplicationRecord
  belongs_to :booking
  belongs_to :ticket_tier

  has_one :user, through: :booking

  before_validation :generate_qr_token, on: :create

  validates :qr_token, presence: true, uniqueness: true

  validate :ticket_tier_belongs_to_booking_event

  def ticket_code
    format("#%05d", id)
  end

  def checked_in?
    checked_in_at.present?
  end

  def check_in!
    with_lock do
      return false if checked_in?

      update!(checked_in_at: Time.current)
    end

    true
  end

  def qr_code_svg
    return unless qr_token.present?

    RQRCode::QRCode.new(qr_token).as_svg(
      module_size: 6,
      standalone: true
    )
  end

  private

  def generate_qr_token
    self.qr_token ||= SecureRandom.hex(32)
  end

  def ticket_tier_belongs_to_booking_event
    return unless booking && ticket_tier
    return if booking.event_id == ticket_tier.event_id

    errors.add(:ticket_tier, "must belong to the booking's event")
  end
end
