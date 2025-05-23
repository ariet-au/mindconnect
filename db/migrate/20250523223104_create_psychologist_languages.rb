class CreatePsychologistLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_languages do |t|
      t.references :psychologist_profile, null: false, foreign_key: true
      t.references :language, null: false, foreign_key: true

      t.timestamps
    end
  end
end
