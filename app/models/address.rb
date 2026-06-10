class Address < ApplicationRecord
  has_many :links

  validates :name, presence: true,
      uniqueness: { scope: :address_type, conditions: -> { where(deleted_at: nil) } }

  validates :address_type, presence: true
end
