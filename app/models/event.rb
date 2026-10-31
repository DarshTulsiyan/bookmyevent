
class Event < ApplicationRecord
  belongs_to :organizer,
             class_name: "User",
             inverse_of: :organized_events

  has_many :ticket_tiers, dependent: :destroy

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }, default: :pending, validate: true

  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }

  validates :title, presence: true
  validates :venue, presence: true
  validates :starts_at, presence: true

  validates :total_capacity,
            numericality: { only_integer: true, greater_than: 0 }

  # Only checked when the date changes, so a past event can still be edited.
  validate :starts_at_in_future, if: :starts_at_changed?

  validate :ticket_tiers_capacity_within_limit

  # Approved events are public; others only to their organizer and admins.
  def visible_to?(user)
    approved? || (user.present? && (user == organizer || user.admin?))
  end

  def seats_left
    ticket_tiers.reload.sum { |tier| tier.seats_left }
  end

  private

  def starts_at_in_future
    return if starts_at.blank? || starts_at.future?

    errors.add(:starts_at, "must be in the future")
  end

  def ticket_tiers_capacity_within_limit
    return unless persisted?
    return if total_capacity.nil?

    tiers_capacity = TicketTier.where(event_id: id).sum(:capacity)

    if tiers_capacity > total_capacity
      errors.add(
        :total_capacity,
        "cannot be less than the combined ticket tier capacities"
      )
    end
  end
end
