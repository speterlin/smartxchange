class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.integer :author_id, null: false
      t.string :commentable_type, null: false
      t.integer :commentable_id, null: false

      t.timestamps
    end
    add_index :comments, :author_id
    add_index :comments, :commentable_type
    add_index :comments, :commentable_id

  end
end
