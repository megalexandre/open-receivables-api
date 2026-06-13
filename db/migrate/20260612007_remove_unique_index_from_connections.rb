class RemoveUniqueIndexFromConnections < ActiveRecord::Migration[8.1]
  def change
    remove_index :connections, name: 'idx_connections_address_numero_active'
  end
end
