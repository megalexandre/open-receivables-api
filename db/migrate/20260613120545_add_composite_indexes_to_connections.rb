class AddCompositeIndexesToConnections < ActiveRecord::Migration[8.1]
  def change
    # Composite index for filtering active/inactive connections by address
    # Covers: WHERE deleted_at IS NULL AND address_id = ?
    add_index :connections, [:deleted_at, :address_id],
              name: 'idx_connections_deleted_at_address_id',
              algorithm: :inplace

    # Composite index for members: deleted_at + name (for JOINs + LIKE filter)
    # Even though LIKE '%x%' can't use index fully, it helps with deleted_at filtering
    add_index :members, [:deleted_at, :name],
              name: 'idx_members_deleted_at_name',
              algorithm: :inplace

    # Composite index for addresses: deleted_at (for JOINs)
    # Already covered by idx_addresses_on_deleted_at, but adding here for consistency
    add_index :categories, [:deleted_at, :id],
              name: 'idx_categories_deleted_at_id',
              algorithm: :inplace
  end
end
