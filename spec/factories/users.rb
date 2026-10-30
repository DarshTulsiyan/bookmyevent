FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    role { :attendee }
    suspended { false }

    trait :organizer do
      role { :organizer }
    end
  end
end
