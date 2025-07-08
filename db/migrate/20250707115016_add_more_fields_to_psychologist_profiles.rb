class AddMoreFieldsToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :psychologist_profiles, :about_clients, :text
    add_column :psychologist_profiles, :about_issues, :text
    add_column :psychologist_profiles, :about_specialties, :text
    add_column :psychologist_profiles, :primary_contact_method, :string
  end
end
