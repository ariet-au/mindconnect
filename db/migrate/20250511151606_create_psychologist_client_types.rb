class CreatePsychologistClientTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_client_types do |t|
      t.belongs_to :psychologist_profile, null: false, foreign_key: true
      t.belongs_to :client_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
