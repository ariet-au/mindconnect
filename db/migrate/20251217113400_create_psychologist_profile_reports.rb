class CreatePsychologistProfileReports < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_profile_reports do |t|
      t.references :psychologist_profile, null: false, foreign_key: true

      t.references :reporter_user,
                   null: true,
                   foreign_key: { to_table: :users }

      t.string :reporter_phone
      t.string :reporter_email

      t.integer :reason, null: false
      t.text :message

      t.integer :status, default: 0, null: false

      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
