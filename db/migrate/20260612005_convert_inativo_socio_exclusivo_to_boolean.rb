class ConvertInativoSocioExclusivoToBoolean < ActiveRecord::Migration[8.1]
  def change
    change_column :connections, :inativo, :boolean, default: false, null: false
    change_column :connections, :socio_exclusivo, :boolean, default: false, null: false
  end
end
