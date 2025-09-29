class AddPsychologyDegreeSupervisionAndInstagramToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :psychologist_profiles, :has_psychology_degree, :boolean, default: false, null: false
    add_column :psychologist_profiles, :supervision, :boolean, default: false, null: false
    add_column :psychologist_profiles, :instagram, :string
  end
end
