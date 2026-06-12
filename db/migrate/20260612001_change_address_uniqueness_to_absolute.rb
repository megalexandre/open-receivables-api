class ChangeAddressUniquenessToAbsolute < ActiveRecord::Migration[8.1]
  def up
    remove_index :addresses, name: 'idx_address_type_name_active_unique'

    execute 'ALTER TABLE addresses DROP COLUMN name_active;'

    add_index :addresses, [:address_type, :name], unique: true, name: 'idx_address_type_name_unique'
  end

  def down
    remove_index :addresses, name: 'idx_address_type_name_unique'

    execute <<~SQL
      ALTER TABLE addresses
        ADD COLUMN name_active VARCHAR(255)
          GENERATED ALWAYS AS (IF(deleted_at IS NULL, name, NULL)) VIRTUAL;
    SQL

    add_index :addresses, [:address_type, :name_active], unique: true, name: 'idx_address_type_name_active_unique'
  end
end
