FactoryBot.define do
  factory :invoice do
    connection

    due_date { 15.days.from_now.to_date }
    reference_date { Date.current.beginning_of_month }
    paid_at { nil }
    amount_partner { 100.50 }
    amount_water { nil }
  end
end
