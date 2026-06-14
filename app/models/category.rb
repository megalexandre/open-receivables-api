class Category < ApplicationRecord
  MEMBER_TYPES = ['Sócio Fundador', 'Sócio Efetivo', 'Sócio Temporário'].freeze

  validates :name,        presence: true,
                          uniqueness: { scope: :member_type,
                                        message: 'já existe uma categoria cadastrada com este nome e grupo' }
  validates :member_type, presence: true, inclusion: { in: MEMBER_TYPES }

  def amount_water_money
    Money.from_amount(read_attribute(:amount_water), :brl)
  end

  def amount_partner_money
    Money.from_amount(read_attribute(:amount_partner), :brl)
  end
end
