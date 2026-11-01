FactoryBot.define do
  factory :booking do
    association :user
    association :event
  end
end
