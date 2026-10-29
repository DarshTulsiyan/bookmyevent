class User < ApplicationRecord
  has_secure_password

  has_many :organized_events,
           class_name: "Event",
           foreign_key: :organizer_id,
           inverse_of: :organizer

  enum :role, {
    attendee: 0,
    organizer: 1,
    admin: 2
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
end
