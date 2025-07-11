class FixTutorColumnTypeOnUsers < ActiveRecord::Migration[7.2]
  def up
    # 1. Add a new boolean column
    add_column :users, :tutor_tmp, :boolean, default: false

    # 2. Migrate clean values
    User.reset_column_information
    User.find_each do |user|
      clean_value = ActiveModel::Type::Boolean.new.cast(user.tutor)
      user.update_column(:tutor_tmp, clean_value)
    end

    # 3. Remove old column and rename the new one
    remove_column :users, :tutor
    rename_column :users, :tutor_tmp, :tutor
  end

  def down
    add_column :users, :tutor_tmp, :string

    User.reset_column_information
    User.find_each do |user|
      string_value = user.tutor ? 't' : 'f'
      user.update_column(:tutor_tmp, string_value)
    end

    remove_column :users, :tutor
    rename_column :users, :tutor_tmp, :tutor
  end
end
