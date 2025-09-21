class AddTelegramVerifiedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :telegram_verified, :boolean
  end
end
