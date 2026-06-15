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

  # Filtra pela competência no formato "MM/YYYY".
  scope :for_reference, ->(reference) {
    month, year = reference.to_s.split('/')
    where('MONTH(reference_date) = ? AND YEAR(reference_date) = ?', month.to_i, year.to_i)
  }
end
