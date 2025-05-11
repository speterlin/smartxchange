class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :chat, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true #user_id = author_id

      t.timestamps null: false
    end
  end
end
