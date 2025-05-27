class AddPrecisionAndScaleToStandardRateInPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
        change_column :psychologist_profiles, :standard_rate, :decimal, precision: 10, scale: 2
  end
end
