FactoryBot.define do
  factory :event do
    association :organizer, factory: [ :user, :organizer ]
    title { "Spring Concert" }
    description { "An evening of live music." }
    venue { "Rudder Auditorium" }
    starts_at { 1.week.from_now }
    total_capacity { 100 }
    status { :pending }
  end
end
