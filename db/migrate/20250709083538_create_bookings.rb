class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :psychologist_profile, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :client_profile, null: false, foreign_key: true
      t.references :internal_client_profile, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
