class CreateAddress < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.string   :address_type, null: false
      t.string   :name,         null: false
      t.text     :notes
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
      t.string   :deleted_by
    end

    add_index :addresses, :deleted_at
    add_index :addresses, [:address_type, :name], unique: true, name: 'idx_address_type_name'
  end
end
