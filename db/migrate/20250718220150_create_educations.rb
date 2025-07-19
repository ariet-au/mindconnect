class CreateEducations < ActiveRecord::Migration[8.0]
  def change
    create_table :educations do |t|
      t.references :psychologist_profile, null: false, foreign_key: true
      t.string :degree, null: false
      t.string :institution
      t.string :field_of_study, null: false
      t.string :graduation_year
      t.string :certificate_url

      t.timestamps
    end
  end
end
