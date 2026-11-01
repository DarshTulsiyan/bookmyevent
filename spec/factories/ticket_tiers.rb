FactoryBot.define do
  factory :ticket_tier do
    event { nil }
    name { "MyString" }
    capacity { 1 }
    tickets_sold { 1 }
  end
end
