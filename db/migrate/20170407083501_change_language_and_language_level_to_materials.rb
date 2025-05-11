class ChangeLanguageAndLanguageLevelToMaterials < ActiveRecord::Migration[7.2]
  def change
    change_column :materials, :language, :string, null: false, default: "Spanish"
    change_column :materials, :language_level, :integer, null: false, default: 3
  end
end
