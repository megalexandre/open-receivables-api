class AddConnectionKeyVirtualColumn < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      ALTER TABLE connections
      ADD COLUMN connection_key VARCHAR(255)
      GENERATED ALWAYS AS (IF(inativo = FALSE, CONCAT(address_id, '-', numero), NULL))
      STORED,
      ADD UNIQUE INDEX idx_connections_key (connection_key) USING BTREE
    SQL
  end

  def down
    remove_index :connections, name: 'idx_connections_key'
    remove_column :connections, :connection_key
  end
end
