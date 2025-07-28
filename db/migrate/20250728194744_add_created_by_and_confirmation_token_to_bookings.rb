class AddCreatedByAndConfirmationTokenToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :created_by, :string
    add_column :bookings, :confirmation_token, :string
    add_index :bookings, :confirmation_token, unique: true
  end
end
