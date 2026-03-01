class RemoveEmbeddingFromPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_index :psychologist_profiles, :embedding if index_exists?(:psychologist_profiles, :embedding)
    remove_column :psychologist_profiles, :embedding if column_exists?(:psychologist_profiles, :embedding)
  end
end