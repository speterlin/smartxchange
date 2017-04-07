class AddLanguageAndLanguageLevelToMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :language, :string
    add_column :materials, :language_level, :integer
  end
end
