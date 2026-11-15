
class Event < ApplicationRecord
  belongs_to :organizer,
             class_name: "User",
             inverse_of: :organized_events

  has_many :bookings, dependent: :restrict_with_error
  has_many :ticket_tiers, dependent: :destroy
  has_one_attached :authorization_document

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    draft: 3
  }, default: :draft, validate: true

  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }
  scope :publicly_visible, -> { approved.where(starts_at: Time.current..).order(:starts_at) }

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
    publicly_visible? || (user.present? && (user == organizer || user.admin?))
  end

  def publicly_visible?
    approved? && starts_at.present? && starts_at >= Time.current
  end

  def seats_left
    ticket_tiers.sum(&:seats_left)
  end

  def submittable_for_review?
    draft? || rejected?
  end

  def submit_for_review(blob)
    with_lock do
      unless submittable_for_review?
        errors.add(:status, "must be draft or rejected to submit for review")
        next false
      end

      self.authorization_document = blob
      update(status: :pending, rejection_reason: nil)
    end
  end

  def approve
    review_pending_event do
      unless authorization_document.attached?
        errors.add(:authorization_document, "must be attached before approval")
        next false
      end

      update(status: :approved)
    end
  end

  def reject(reason:)
    review_pending_event do
      reason = reason.to_s.strip
      if reason.blank?
        errors.add(:rejection_reason, "can't be blank")
        next false
      end

      update(status: :rejected, rejection_reason: reason)
    end
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

  def review_pending_event
    with_lock do
      unless pending?
        errors.add(:status, "can only be changed while pending")
        next false
      end

      yield
    end
  end
end
