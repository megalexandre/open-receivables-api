class AddUniqueIndexToConnections < ActiveRecord::Migration[8.1]
  def change
    add_index :connections, [:address_id, :numero],
              name: 'idx_connections_address_numero_active',
              unique: true,
              where: 'inativo = 0',
              comment: 'Unique constraint for active connections only (inativo = 0)'
  end
end
