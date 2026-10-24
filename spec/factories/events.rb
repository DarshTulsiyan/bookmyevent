FactoryBot.define do
  factory :event do
    organizer { nil }
    title { "MyString" }
    description { "MyText" }
    venue { "MyString" }
    starts_at { "2026-10-24 15:10:20" }
    total_capacity { 1 }
    status { 1 }
  end
end
