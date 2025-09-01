class CreateClientInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :client_infos do |t|
      t.string :first_name
      t.string :last_name
      t.integer :year_of_birth
      t.string :city
      t.string :timezone
      t.text :reason_for_therapy
      t.references :psychologist_profile, null: false, foreign_key: true
      t.string :submitted_by, null: false

      t.timestamps
    end
  end
end
