class ChangeMemberDocumentUniquenessToAbsolute < ActiveRecord::Migration[8.1]
  def up
    remove_index :members, name: 'idx_members_document_active_unique'

    execute 'ALTER TABLE members DROP COLUMN document_active;'

    add_index :members, :document, unique: true, name: 'idx_members_document_unique'
  end

  def down
    remove_index :members, name: 'idx_members_document_unique'

    execute <<~SQL
      ALTER TABLE members
        ADD COLUMN document_active VARCHAR(14)
          GENERATED ALWAYS AS (IF(deleted_at IS NULL, document, NULL)) VIRTUAL;
    SQL

    add_index :members, :document_active, unique: true, name: 'idx_members_document_active_unique'
  end
end
