class Address < ApplicationRecord
  include SoftDeletable

  has_many :connections

  validates :name, presence: true,
      uniqueness: { scope: :address_type,
                    message: 'já existe um endereço cadastrado com este tipo e nome' }

  validates :address_type, presence: true
end
