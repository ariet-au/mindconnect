class CreateUserSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sessions do |t|
      t.references :user, foreign_key: true, null: true
      t.string :session_id
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :duration_seconds
      t.string :device_type

      t.timestamps
    end
    add_index :user_sessions, :started_at
  end
end
