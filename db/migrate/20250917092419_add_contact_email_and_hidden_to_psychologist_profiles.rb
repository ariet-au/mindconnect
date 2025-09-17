class AddContactEmailAndHiddenToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :psychologist_profiles, :contact_email, :string
    add_column :psychologist_profiles, :hidden, :boolean, default: false, null: false
  end
end
