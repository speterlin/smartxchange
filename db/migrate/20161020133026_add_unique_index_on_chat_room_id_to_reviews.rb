class AddUniqueIndexOnChatRoomIdToReviews < ActiveRecord::Migration[7.2]
  def change
    add_index :reviews, [:chat_room_id, :reviewer_id], unique: true
  end
end
