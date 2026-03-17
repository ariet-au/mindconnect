class AddVisitorIdToTrackingTables < ActiveRecord::Migration[8.0]
  def change
    # Only add to page_views if it's missing
    unless column_exists?(:page_views, :visitor_id)
      add_column :page_views, :visitor_id, :string
    end
    add_index :page_views, :visitor_id unless index_exists?(:page_views, :visitor_id)

    # Only add to user_sessions if it's missing
    unless column_exists? :user_sessions, :visitor_id
      add_column :user_sessions, :visitor_id, :string
    end
    add_index :user_sessions, :visitor_id unless index_exists?(:user_sessions, :visitor_id)
  end
end