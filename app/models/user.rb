class User < ApplicationRecord
  has_secure_password

  has_many :organized_events,
           class_name: "Event",
           foreign_key: :organizer_id,
           inverse_of: :organizer

  has_many :bookings, dependent: :restrict_with_error
  has_many :tickets, through: :bookings
  has_many :reviewed_admin_access_requests,
           class_name: "AdminAccessRequest",
           foreign_key: :reviewed_by_id,
           inverse_of: :reviewed_by

  enum :role, {
    attendee: 0,
    organizer: 1,
    admin: 2,
    sudo: 3
  }, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :role, presence: true

  validates :password,
            length: { minimum: 8 },
            allow_nil: true

  def can_access_role_view?(requested_role)
    return true if sudo?

    {
      "attendee" => attendee?,
      "organizer" => organizer?,
      "admin" => admin?
    }.fetch(requested_role.to_s, false)
  end

  def can_review_admin_access_requests?
    admin? && admin_access_request_reviewer?
  end
end
