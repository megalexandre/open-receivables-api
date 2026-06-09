class AddVoterToMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :voter, :boolean, null: false, default: false
  end
end
