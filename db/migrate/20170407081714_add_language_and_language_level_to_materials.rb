class AddLanguageAndLanguageLevelToMaterials < ActiveRecord::Migration[7.2]
  def change
    add_column :materials, :language, :string
    add_column :materials, :language_level, :integer
  end
end
