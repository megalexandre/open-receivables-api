class RenameConnectionsColumnsToEnglish < ActiveRecord::Migration[8.1]
  def up
    remove_index :connections, name: 'idx_connections_key'
    remove_column :connections, :connection_key

    rename_column :connections, :id_pessoa, :member_id
    rename_column :connections, :id_categoria_socio, :category_id
    rename_column :connections, :numero, :number
    rename_column :connections, :datamatricula, :registration_date
    rename_column :connections, :inativo, :inactive
    rename_column :connections, :socio_exclusivo, :partner_exclusive

    rename_index :connections, 'idx_connection_id_pessoa', 'idx_connection_member_id'
    rename_index :connections, 'idx_connection_id_categoria_socio', 'idx_connection_category_id'

    # Recreate virtual column with new names
    execute <<-SQL
      ALTER TABLE connections
      ADD COLUMN connection_key VARCHAR(255)
      GENERATED ALWAYS AS (IF(inactive = FALSE, CONCAT(address_id, '-', number), NULL))
      STORED,
      ADD UNIQUE INDEX idx_connections_key (connection_key) USING BTREE
    SQL
  end

  def down
    remove_index :connections, name: 'idx_connections_key'
    remove_column :connections, :connection_key

    rename_column :connections, :member_id, :id_pessoa
    rename_column :connections, :category_id, :id_categoria_socio
    rename_column :connections, :number, :numero
    rename_column :connections, :registration_date, :datamatricula
    rename_column :connections, :inactive, :inativo
    rename_column :connections, :partner_exclusive, :socio_exclusivo

    rename_index :connections, 'idx_connection_member_id', 'idx_connection_id_pessoa'
    rename_index :connections, 'idx_connection_category_id', 'idx_connection_id_categoria_socio'

    execute <<-SQL
      ALTER TABLE connections
      ADD COLUMN connection_key VARCHAR(255)
      GENERATED ALWAYS AS (IF(inativo = FALSE, CONCAT(address_id, '-', numero), NULL))
      STORED,
      ADD UNIQUE INDEX idx_connections_key (connection_key) USING BTREE
    SQL
  end
end
