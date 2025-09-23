class AddStatusAndArchivedAtToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :status, :integer, default: 0, null: false
    add_column :services, :archived_at, :datetime

    add_index :services, :status
    add_index :services, :archived_at
  end
end
