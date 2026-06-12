class AddUniqueIndexToWaterAnalyses < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      DELETE wa FROM water_analyses wa
      INNER JOIN water_analyses dup
        ON dup.reference_date = wa.reference_date
       AND dup.parameter      = wa.parameter
       AND dup.id > wa.id;
    SQL

    add_index :water_analyses, [:reference_date, :parameter],
              unique: true, name: 'idx_water_analyses_reference_parameter_unique'
  end

  def down
    remove_index :water_analyses, name: 'idx_water_analyses_reference_parameter_unique'
  end
end
