class AddServiceTypesToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :psychologist_profiles, :in_person, :boolean
    add_column :psychologist_profiles, :online, :boolean
  end
end
