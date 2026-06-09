FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Categoria #{n}" }
    member_type     { Category::MEMBER_TYPES.first }
    amount_water    { 50.0 }
    amount_partner  { 30.0 }
    has_hydrometer  { false }
  end
end
