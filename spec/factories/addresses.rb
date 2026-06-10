FactoryBot.define do
  factory :address do
    address_type    { 'Rua' }
    sequence(:name) { |n| "Logradouro #{n}" }
  end
end
