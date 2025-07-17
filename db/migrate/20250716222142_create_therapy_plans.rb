class CreateTherapyPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :therapy_plans do |t|
      t.references :internal_client_profile, null: false, foreign_key: true
      t.references :issue, foreign_key: true
      t.references :specialties, foreign_key: true
      t.text :diagnosis
      t.text :short_term_goals
      t.text :long_term_goals
      t.text :intervention_details
      t.string :frequency
      t.integer :duration_weeks
      t.text :progress_metrics
      t.string :status, default: "draft", null: false
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
