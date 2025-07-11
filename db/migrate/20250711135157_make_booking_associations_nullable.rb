class MakeBookingAssociationsNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bookings, :service_id, true
    change_column_null :bookings, :client_profile_id, true
    change_column_null :bookings, :internal_client_profile_id, true
  end
end
