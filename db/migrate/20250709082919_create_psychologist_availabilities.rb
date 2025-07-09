class CreatePsychologistAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_availabilities do |t|
      t.references :psychologist_profile, null: false, foreign_key: true
      t.integer :day_of_week
      t.time :start_time_of_day
      t.time :end_time_of_day
      t.string :timezone  

      t.timestamps
    end
  end
end
