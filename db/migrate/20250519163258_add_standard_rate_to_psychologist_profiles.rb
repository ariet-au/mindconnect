class AddStandardRateToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :psychologist_profiles, :standard_rate, :decimal
    add_column :psychologist_profiles, :currency, :string
  end
end
