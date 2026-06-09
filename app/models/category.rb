class Category < ApplicationRecord
  MEMBER_TYPES = ['Sócio Fundador', 'Sócio Efetivo', 'Sócio Temporário'].freeze

  FEATURE_CODE = 1

  ERROR_CODES = {
    [ :name,        :taken   ] => "E_#{FEATURE_CODE}_1",
    [ :member_type, :blank   ] => "E_#{FEATURE_CODE}_2",
    [ :member_type, :inclusion ] => "E_#{FEATURE_CODE}_3",
  }.freeze

  validates :name,        presence: true, uniqueness: { scope: :member_type }
  validates :member_type, presence: true, inclusion: { in: MEMBER_TYPES }

  def self.error_code(attribute, type)
    ERROR_CODES[[attribute.to_sym, type.to_sym]] || "E_#{FEATURE_CODE}_0"
  end

  def amount_water_money
    Money.from_amount(read_attribute(:amount_water), :brl)
  end

  def amount_partner_money
    Money.from_amount(read_attribute(:amount_partner), :brl)
  end

  def as_json(options = {})
    attributes.merge(
      "amount_water"  => amount_water_money.to_d.to_f,
      "amount_partner" => amount_partner_money.to_d.to_f,
    )
  end
end
