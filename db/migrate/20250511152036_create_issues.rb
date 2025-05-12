class CreateIssues < ActiveRecord::Migration[8.0]
  def change
    create_table :issues do |t|
      t.string :name
      t.text :description
      t.string :category
      t.string :severity_level

      t.timestamps
    end
  end
end
