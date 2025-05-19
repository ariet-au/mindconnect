class AddCurrencyToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :currency, :string, limit: 3
  end
end
