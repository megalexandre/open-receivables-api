class RenameLinksToConnections < ActiveRecord::Migration[8.1]
  def change
    rename_table :links, :connections

    rename_index :connections, 'idx_link_id_pessoa',            'idx_connection_id_pessoa'
    rename_index :connections, 'idx_link_address_id',           'idx_connection_address_id'
    rename_index :connections, 'idx_link_id_categoria_socio',   'idx_connection_id_categoria_socio'
    rename_index :connections, 'idx_links_deleted_at',          'idx_connections_deleted_at'
  end
end
