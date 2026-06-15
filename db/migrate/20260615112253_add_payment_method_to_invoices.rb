class AddPaymentMethodToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_column :invoices, :payment_method, :string
  end
end
