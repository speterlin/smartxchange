class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.integer :reviewer_id, null: false
      # maybe review chat_rooms in addition to other people in the future
      t.string :reviewable_type, null: false
      t.integer :reviewable_id, null: false
      t.integer :chat_room_id, null: false
      t.string :language, null: false
      t.integer :language_level, null: false
      t.text :comment

      t.timestamps
    end
    add_index :reviews, :reviewer_id
    add_index :reviews, [:reviewable_type, :reviewable_id]
    add_index :reviews, :chat_room_id
  end
end
