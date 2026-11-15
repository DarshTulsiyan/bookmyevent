FactoryBot.define do
  factory :admin_access_request do
    sequence(:email) { |n| "applicant#{n}@example.com" }
    name { "Access Applicant" }
    reason { "I need access to manage the event platform." }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    status { :pending }
  end
end
