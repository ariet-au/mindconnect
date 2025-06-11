class CreateClientTypesIssuesJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :client_types_issues, id: false do |t|
      t.belongs_to :client_type, null: false, foreign_key: true, index: true
      t.belongs_to :issue, null: false, foreign_key: true, index: true
    end

    add_index :client_types_issues, [:client_type_id, :issue_id], unique: true
  end
end
