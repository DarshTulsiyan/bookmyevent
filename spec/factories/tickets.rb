FactoryBot.define do
  factory :ticket do
    association :ticket_tier
    booking { association(:booking, event: ticket_tier.event) }
    checked_in_at { nil }
  end
end
