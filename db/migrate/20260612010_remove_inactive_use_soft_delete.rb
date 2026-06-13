class RemoveInactiveUseSoftDelete < ActiveRecord::Migration[8.1]
  def up
    remove_index :connections, name: 'idx_connections_key'
    remove_column :connections, :connection_key
    remove_column :connections, :inactive

    # Recreate virtual column using deleted_at instead
    execute <<-SQL
      ALTER TABLE connections
      ADD COLUMN connection_key VARCHAR(255)
      GENERATED ALWAYS AS (IF(deleted_at IS NULL, CONCAT(address_id, '-', number), NULL))
      STORED,
      ADD UNIQUE INDEX idx_connections_key (connection_key) USING BTREE
    SQL
  end

  def down
    remove_index :connections, name: 'idx_connections_key'
    remove_column :connections, :connection_key

    add_column :connections, :inactive, :boolean, default: false, null: false

    execute <<-SQL
      ALTER TABLE connections
      ADD COLUMN connection_key VARCHAR(255)
      GENERATED ALWAYS AS (IF(inactive = FALSE, CONCAT(address_id, '-', number), NULL))
      STORED,
      ADD UNIQUE INDEX idx_connections_key (connection_key) USING BTREE
    SQL
  end
end
