class RemoveReadAtToReads < ActiveRecord::Migration[7.2]
  def change
    remove_column :reads, :read_at
  end
end
