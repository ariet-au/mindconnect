class AddTimeZoneToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :psychologist_profiles, :timezone, :string
  end
end
