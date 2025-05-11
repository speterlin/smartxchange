class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.integer :age, null: false
      t.string :language, null: false
      t.integer :language_level, null: false
      t.string :password_digest, null: false
      t.string :session_token, null: false
      t.string :image
      t.boolean :active, null: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :session_token
  end
end
