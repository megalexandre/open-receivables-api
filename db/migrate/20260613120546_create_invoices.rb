class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.bigint   :connection_id, null: false
      t.date     :due_date,      null: false
      t.date     :reference_date
      t.datetime :paid_at
      t.decimal  :amount_partner, precision: 10, scale: 2
      t.decimal  :amount_water,   precision: 10, scale: 2
      t.datetime :deleted_at
      t.string   :deleted_by
      t.string   :created_by
      t.string   :updated_by
      t.timestamps
    end
    add_index :invoices, :connection_id
    add_index :invoices, :deleted_at
    add_index :invoices, :due_date
    add_index :invoices, :reference_date
    add_foreign_key :invoices, :connections
  end
end
