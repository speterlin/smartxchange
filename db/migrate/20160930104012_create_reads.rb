class CreateReads < ActiveRecord::Migration[7.2]
  def change
    create_table :reads do |t|
      t.integer :user_id, null: false
      t.string :readable_type
      t.integer :readable_id
      t.datetime :read_at

      t.timestamps
    end
    add_index  :reads, :user_id
    add_index :reads, [:readable_type, :readable_id]
  end
end
