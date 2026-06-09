class CreateCategory < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string   :name,           null: false
      t.string   :member_type,    null: false
      t.decimal  :amount_water,   precision: 10, scale: 2, default: 0, null: false
      t.decimal  :amount_partner, precision: 10, scale: 2, default: 0, null: false
      t.boolean  :has_hydrometer, default: false
      t.text     :descricao
      t.datetime :created_at,     null: false
      t.datetime :updated_at,     null: false
      t.string   :created_by
      t.string   :updated_by
      t.datetime :deleted_at
      t.string   :deleted_by
    end

    add_index :categories, [:name, :member_type], unique: true, name: 'idx_category_name_member_type'
    add_index :categories, :member_type,                         name: 'idx_category_member_type'
    add_index :categories, :deleted_at,                          name: 'idx_category_deleted_at'
  end
end
