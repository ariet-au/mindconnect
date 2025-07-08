class CreateClientProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :client_profiles do |t|
      t.string :frist_name
      t.string :last_name
      t.date :dob
      t.string :gender
      t.string :country
      t.string :city
      t.text :address
      t.string :timezone
      t.string :phone_number1
      t.string :phone_number2
      t.string :telegram
      t.string :whatsapp
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
