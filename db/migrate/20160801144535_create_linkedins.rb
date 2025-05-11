class CreateLinkedins < ActiveRecord::Migration[7.2]
  def change
    create_table :linkedins do |t|
      t.integer :user_id, null: false
      t.string :public_url
      t.string :industry
      t.string :summary

      t.timestamps
    end
  end
end
