class CreateLink < ActiveRecord::Migration[8.1]
  def change
    create_table :links do |t|
      t.bigint  :id_pessoa,          null: false
      t.bigint  :address_id,         null: false
      t.bigint  :id_categoria_socio, null: false
      t.string  :numero
      t.date    :datamatricula
      t.binary   :inativo,         limit: 1
      t.binary   :socio_exclusivo, limit: 1
      t.datetime :created_at,      null: false
      t.datetime :updated_at,      null: false
      t.string   :created_by
      t.string   :updated_by
      t.datetime :deleted_at
      t.string   :deleted_by
    end

    add_index :links, :id_pessoa,          name: 'idx_link_id_pessoa'
    add_index :links, :address_id,         name: 'idx_link_address_id'
    add_index :links, :id_categoria_socio, name: 'idx_link_id_categoria_socio'
    add_index :links, :deleted_at,         name: 'idx_links_deleted_at'

    add_foreign_key :links, :members,    column: :id_pessoa
    add_foreign_key :links, :addresses,  column: :address_id
    add_foreign_key :links, :categories, column: :id_categoria_socio
  end
end
