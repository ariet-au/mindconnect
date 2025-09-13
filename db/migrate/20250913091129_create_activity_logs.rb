class CreateActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_type, null: false
      t.references :target, polymorphic: true, index: true
      t.jsonb :metadata, default: {}
      t.datetime :occurred_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    add_index :activity_logs, [:user_id, :action_type]
    add_index :activity_logs, :occurred_at
  end
end
