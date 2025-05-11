class RenameTypeColumnToPackages < ActiveRecord::Migration[7.2]
  def change
    rename_column :packages, :type, :classification
  end
end
