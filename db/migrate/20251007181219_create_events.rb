class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :psychologist_profile, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :price
      t.string  :currency
      t.string :timezone
      t.boolean :online
      t.string :address
      t.string :online_link
      t.boolean :hide_details_until_approved
      t.integer :audience
      t.integer :access_type
      t.integer :visibility
      t.integer :status
      t.integer :capacity
      t.datetime :registration_ends_at
      t.datetime :archived_at
      t.string :language
      t.integer :views_count
      t.integer :registrations_count
      t.string :slug
      t.boolean :approved_by_admin
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :events, :slug
  end
end
