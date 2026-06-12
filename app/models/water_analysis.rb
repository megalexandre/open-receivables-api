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

  def as_json(options = {})
    {
      'id'         => id.to_s,
      'reference'  => reference_date.strftime('%m/%Y'),
      'parameter'  => parameter,
      'required'   => required_value.to_f,
      'analyzed'   => analyzed_value.to_f,
      'conformity' => conformity_value.to_f,
      'compliant'  => analyzed_value.to_f <= conformity_value.to_f,
    }
  end
end
