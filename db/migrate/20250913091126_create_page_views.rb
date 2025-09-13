class CreatePageViews < ActiveRecord::Migration[8.0]
  def change
    create_table :page_views do |t|
      t.references :user, foreign_key: true, null: true
      t.string :session_id
      t.string :url
      t.string :referrer
      t.string :ip_address
      t.string :user_agent
      t.datetime :viewed_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    add_index :page_views, :viewed_at
  end
end
