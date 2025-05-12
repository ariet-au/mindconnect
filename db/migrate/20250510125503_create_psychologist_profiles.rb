class CreatePsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.text :about_me
      t.string :first_name
      t.string :last_name
      t.integer :years_of_experience
      t.string :license_number
      t.string :country
      t.string :city
      t.string :address
      t.string :telegram
      t.string :whatsapp
      t.string :contact_phone
      t.string :contact_phone2
      t.string :contact_phone3
      t.integer :gender
      t.string :education
      t.boolean :is_doctor
      t.string :is_degree_boolean

      t.timestamps
    end
  end
end
