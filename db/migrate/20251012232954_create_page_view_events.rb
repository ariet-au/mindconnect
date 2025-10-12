class CreatePageViewEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :page_view_events do |t|
      t.references :page_view, null: false, foreign_key: true
      t.string :event_type
      t.json :metadata

      t.timestamps
    end
  end
end
