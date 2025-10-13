class DropTherapyPlansAndProgressNotesAndInternalClientProfiles < ActiveRecord::Migration[8.0]
  def up
    # Remove foreign key constraints before dropping tables
    if foreign_key_exists?(:bookings, :internal_client_profiles)
      remove_foreign_key :bookings, :internal_client_profiles
    end

    if column_exists?(:bookings, :internal_client_profile_id)
      remove_column :bookings, :internal_client_profile_id
    end

    drop_table :progress_notes, if_exists: true
    drop_table :therapy_plans, if_exists: true
    drop_table :internal_client_profiles, if_exists: true
  end

  def down
    create_table :internal_client_profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number1
      t.string :phone_number2
      t.string :telegram
      t.string :whatsapp
      t.string :gender
      t.date :dob
      t.string :country
      t.string :city
      t.text :address
      t.string :internal_reference_number
      t.string :preferred_contact_method
      t.string :emergency_contact_name
      t.string :emergency_contact_phone
      t.string :emergency_contact_relationship
      t.text :reason_for_referral
      t.string :gp_name
      t.text :gp_contact_info
      t.text :initial_assessment_summary
      t.text :risk_assessment_summary
      t.text :treatment_plan_summary
      t.boolean :first_time_therapy
      t.integer :status
      t.references :psychologist_profile, null: false, foreign_key: true
      t.references :client_profile, foreign_key: true
      t.timestamps
    end

    create_table :therapy_plans do |t|
      t.references :internal_client_profile, null: false, foreign_key: true
      t.references :issue, foreign_key: true
      t.references :specialties, foreign_key: { to_table: :specialties }
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

    create_table :progress_notes do |t|
      t.references :therapy_plan, null: false, foreign_key: true
      t.references :booking, foreign_key: true
      t.text :notes
      t.text :homework_assigned
      t.integer :assessment_score
      t.date :note_date
      t.timestamps
    end

    # Re-add the foreign key and column if rollback
    add_column :bookings, :internal_client_profile_id, :bigint unless column_exists?(:bookings, :internal_client_profile_id)
    add_foreign_key :bookings, :internal_client_profiles unless foreign_key_exists?(:bookings, :internal_client_profiles)
  end
end
