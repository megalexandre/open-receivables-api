class AddUniqueConstraintToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_index :invoices, [:connection_id, :reference_date],
              unique: true,
              where: 'deleted_at IS NULL',
              name: 'idx_invoices_unique_connection_reference'
  end
end
