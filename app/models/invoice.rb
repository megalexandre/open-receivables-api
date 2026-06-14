class Invoice < ApplicationRecord
  include SoftDeletable

  belongs_to :connection

  validates :connection_id, :due_date, presence: true
  validates :connection_id, uniqueness: { scope: :reference_date, message: 'já existe uma fatura para esta ligação neste período' }, allow_nil: true
end
