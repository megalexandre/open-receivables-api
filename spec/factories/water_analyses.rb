FactoryBot.define do
  factory :water_analysis do
    parameter        { WaterAnalysis::PARAMETERS.first }
    reference_date   { Date.new(2026, 6, 1) }
    required_value   { 5.0 }
    analyzed_value   { 1.0 }
    conformity_value { 5.0 }
  end
end
