class AdminAccessRequest < ApplicationRecord
  has_secure_password

  belongs_to :reviewed_by,
             class_name: "User",
             optional: true,
             inverse_of: :reviewed_admin_access_requests

  enum :status, { pending: 0, approved: 1, rejected: 2 }, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { conditions: -> { where(status: :pending) } }
  validates :reason, presence: true, length: { maximum: 1_000 }
  validates :reviewer_note, length: { maximum: 1_000 }, allow_nil: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password_confirmation, presence: true, on: :create

  validate :email_is_not_registered

  def approve_by!(reviewer:, reviewer_note: nil)
    with_lock do
      ensure_pending!
      ensure_reviewer!(reviewer)

      if User.where("LOWER(email) = ?", email).exists?
        errors.add(:email, "is already registered")
        raise ActiveRecord::RecordInvalid, self
      end

      user = User.create!(
        name: name,
        email: email,
        role: :admin,
        password_digest: password_digest
      )

      record_decision!(status: :approved, reviewer: reviewer, reviewer_note: reviewer_note)
      user
    end
  end

  def reject_by!(reviewer:, reviewer_note: nil)
    with_lock do
      ensure_pending!
      ensure_reviewer!(reviewer)

      record_decision!(status: :rejected, reviewer: reviewer, reviewer_note: reviewer_note)
    end
  end

  private

  def email_is_not_registered
    return if email.blank?
    return unless new_record? || will_save_change_to_email?
    return unless User.where("LOWER(email) = ?", email).exists?

    errors.add(:email, "is already registered")
  end

  def ensure_pending!
    return if pending?

    errors.add(:base, "Only pending requests can be reviewed")
    raise ActiveRecord::RecordInvalid, self
  end

  def ensure_reviewer!(reviewer)
    return if reviewer&.can_review_admin_access_requests?

    errors.add(:base, "Only the designated administrator can review requests")
    raise ActiveRecord::RecordInvalid, self
  end

  def record_decision!(status:, reviewer:, reviewer_note:)
    self.reviewer_note = reviewer_note
    raise ActiveRecord::RecordInvalid, self unless valid?

    update_columns(
      status: self.class.statuses.fetch(status.to_s),
      reviewed_by_id: reviewer.id,
      reviewer_note: self.reviewer_note,
      reviewed_at: Time.current,
      password_digest: nil,
      updated_at: Time.current
    )
  end
end
