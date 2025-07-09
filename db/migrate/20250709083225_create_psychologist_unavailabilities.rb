class CreatePsychologistUnavailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_unavailabilities do |t|
      t.references :psychologist_profile, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :reason
      t.boolean :recurring, default: false
      t.integer :day_of_week
      t.date :recurring_until
      t.string :timezone  

      t.timestamps
    end
  end
end
