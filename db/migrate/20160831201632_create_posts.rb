class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.text :content, null: false
      t.integer :author_id, null: false
      t.integer :board_id, null: false

      t.timestamps
    end
    add_index :posts, :author_id

  end
end
