class CreateClientContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :client_contacts do |t|
      t.references :client_info, null: false, foreign_key: true
      t.string :method
      t.string :value

      t.timestamps
    end
  end
end
