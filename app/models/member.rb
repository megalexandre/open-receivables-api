class Member < ApplicationRecord
  include SoftDeletable

  before_validation { self.document = document&.gsub(/\D/, '') }

  validates :name,     presence: true
  validates :document, presence: true, length: { minimum: 11, maximum: 14 },
                       uniqueness: { message: 'já existe um sócio cadastrado com este documento' }


  validates :voter,    inclusion: { in: [true, false] }
end
