FactoryBot.define do
  factory :ticket_tier do
    association :event
    sequence(:name) { |n| "Tier #{n}" }
    capacity { 10 }
    tickets_sold { 0 }
  end
end
