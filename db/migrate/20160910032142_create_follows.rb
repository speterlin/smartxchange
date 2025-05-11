class CreateFollows < ActiveRecord::Migration[7.2]
  def change
    create_table :follows do |t|
      t.integer :follower_id
      t.string :followable_type
      t.integer :followable_id

      t.timestamps
    end

    add_index :follows, :follower_id
    add_index :follows, :followable_type
    add_index :follows, :followable_id
  end
end
