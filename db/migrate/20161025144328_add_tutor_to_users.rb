class AddTutorToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :tutor, :boolean, null:false, default: false
  end
end
