class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :duration_minutes
      t.integer :delivery_method

      t.timestamps
    end
  end
end
