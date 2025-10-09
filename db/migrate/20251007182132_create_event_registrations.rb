class CreateEventRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :event_registrations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.references :client_info, foreign_key: true
      t.integer :status
      t.datetime :registered_at
      t.datetime :approved_at
      t.datetime :cancelled_at
      t.text :cancellation_reason
      t.boolean :attended
      t.string :timezone
     
      t.decimal :price
      t.string :currency
      t.datetime :paid_at
      

      t.timestamps
    end
  end
end
