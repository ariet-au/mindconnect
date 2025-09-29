class RemoveIsDegreeBooleanFromPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :psychologist_profiles, :is_degree_boolean, :string
  end
end
