class CreateWaterAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :water_analyses do |t|
      t.string   :parameter,       null: false
      t.date     :reference_date,  null: false
      t.decimal  :required_value,  precision: 10, scale: 4
      t.decimal  :analyzed_value,  precision: 10, scale: 4
      t.decimal  :conformity_value, precision: 10, scale: 4
      t.datetime :created_at,       null: false
      t.datetime :updated_at,       null: false
      t.string   :created_by
      t.string   :updated_by
      t.datetime :deleted_at
      t.string   :deleted_by
    end

    add_index :water_analyses, :reference_date, name: 'idx_water_analyses_reference_date'
    add_index :water_analyses, :parameter,      name: 'idx_water_analyses_parameter'
    add_index :water_analyses, :deleted_at,     name: 'idx_water_analyses_deleted_at'
  end
end
