class CreateMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :members do |t|
      t.string   :name,          null: false
      t.string   :document
      t.integer  :member_number
      t.datetime :created_at,    null: false
      t.datetime :updated_at,    null: false
      t.string   :created_by
      t.string   :updated_by
      t.datetime :deleted_at
      t.string   :deleted_by
    end

    add_index :members, :document,  unique: true, name: 'idx_members_document_unique'
    add_index :members, :name,                    name: 'idx_members_name'
    add_index :members, :deleted_at,              name: 'idx_members_deleted_at'
  end
end
