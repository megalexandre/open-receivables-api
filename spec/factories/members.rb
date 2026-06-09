FactoryBot.define do
  factory :member do
    sequence(:name)     { |n| "Sócio #{n}" }
    sequence(:document) { |n| "#{(10_000_000_000 + n).to_s.ljust(11, '0')}" }
    sequence(:member_number, 1)
  end
end
