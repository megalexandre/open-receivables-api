class WaterAnalysis < ApplicationRecord
  PARAMETERS = [
    'Cor Aparente',
    'Turbidez',
    'Cloro Residual',
    'Escherichia Coli',
    'Coliformes Totais',
  ].freeze

  validates :parameter,      presence: true, inclusion: { in: PARAMETERS },
      uniqueness: { scope: :reference_date,
                    message: 'já existe uma análise deste parâmetro para esta referência' }
  validates :reference_date, presence: true
end
