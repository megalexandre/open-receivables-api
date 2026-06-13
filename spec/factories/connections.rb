FactoryBot.define do
  factory :connection do
    address
    association :member, factory: :member
    association :category, factory: :category

    member_id { member.id }
    category_id { category.id }

    sequence(:number) { |n| "#{1000 + n}" }
    registration_date { Date.current }
    partner_exclusive { false }
  end
end
