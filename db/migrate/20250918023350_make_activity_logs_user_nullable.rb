class MakeActivityLogsUserNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :activity_logs, :user_id, true
  end
end
