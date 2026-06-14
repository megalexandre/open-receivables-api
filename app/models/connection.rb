class Connection < ApplicationRecord
  include SoftDeletable

  scope :without_invoice_in_period, ->(month, year) {
    where.not(
      id: Invoice.unscoped
                 .where(deleted_at: nil)
                 .where('MONTH(reference_date) = ? AND YEAR(reference_date) = ?', month, year)
                 .select(:connection_id)
    )
  }

  belongs_to :address
  belongs_to :member,   foreign_key: :member_id
  belongs_to :category, foreign_key: :category_id

  validates :address_id,  presence: true
  validates :member_id,   presence: true
  validates :category_id, presence: true

  validate :unique_address_number_when_active, if: -> { deleted_at.nil? }

  private

  def unique_address_number_when_active
    return if address_id.blank? || number.blank?

    existing = self.class.where(address_id:, number:, deleted_at: nil)
    existing = existing.where.not(id:) if persisted?

    errors.add(:address_id, 'já existe uma ligação ativa com este endereço e número') if existing.exists?
  end
end
