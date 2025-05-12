class CreatePsychologistSpecialties < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_specialties do |t|
      t.belongs_to :psychologist_profile, null: false, foreign_key: true
      t.belongs_to :specialty, null: false, foreign_key: true

      t.timestamps
    end
  end
end
