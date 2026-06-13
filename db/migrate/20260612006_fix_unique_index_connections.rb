class FixUniqueIndexConnections < ActiveRecord::Migration[8.1]
  def change
    remove_index :connections, name: 'idx_connections_address_numero_active'

    add_index :connections, [:address_id, :numero],
              name: 'idx_connections_address_numero_active',
              unique: true,
              where: 'inativo = false',
              comment: 'Unique constraint for active connections only'
  end
end
