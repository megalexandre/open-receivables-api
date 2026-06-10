class Member < ApplicationRecord
  before_validation { self.document = document&.gsub(/\D/, '') }

  validates :name,     presence: true
  validates :document, presence: true, length: { minimum: 11, maximum: 14 },
                       uniqueness: { conditions: -> { where(deleted_at: nil) } }
  validates :voter,    inclusion: { in: [true, false] }
end
