class Address < ApplicationRecord
  has_many :links, foreign_key: :address_id

  FEATURE_CODE = 3

  ERROR_CODES = {
    [ :name, :taken ] => "E_#{FEATURE_CODE}_1",
  }.freeze

  validates :name, presence: true,
                   uniqueness: { scope: :address_type, conditions: -> { where(deleted_at: nil) } }
  validates :address_type, presence: true

  def self.error_code(attribute, type)
    ERROR_CODES[[attribute.to_sym, type.to_sym]] || "E_#{FEATURE_CODE}_0"
  end

  def as_json(options = {})
    super(options).merge("id" => id.to_s)
  end

end
