class Member < ApplicationRecord
  FEATURE_CODE = 2

  ERROR_CODES = {
    [ :document, :taken ] => "E_#{FEATURE_CODE}_1",
  }.freeze

  before_validation { self.document = document&.gsub(/\D/, '') }

  validates :name,     presence: true
  validates :document, presence: true, length: { minimum: 11, maximum: 14 },
                       uniqueness: { conditions: -> { where(deleted_at: nil) } }
  validates :voter,    inclusion: { in: [true, false] }

  def self.error_code(attribute, type)
    ERROR_CODES[[attribute.to_sym, type.to_sym]] || "E_#{FEATURE_CODE}_0"
  end
end
