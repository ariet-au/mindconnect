class AddClientInfoToBookings < ActiveRecord::Migration[8.0]
  def change
    add_reference :bookings, :client_info, null: false, foreign_key: true, null: true
  end
end
