class CreateVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :votes do |t|
      t.integer :value, null: false, limit: 1
      t.string :votable_type, null: false
      t.integer :votable_id, null: false

      t.timestamps
    end
    add_index :votes, :votable_type
    add_index :votes, :votable_id

  end
end
