class CreateInternalClientProfiles < ActiveRecord::Migration[8.0]
  def change
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
      t.references :client_profile, null: true, foreign_key: true

      t.timestamps
    end

    add_index :internal_client_profiles, [:psychologist_profile_id, :internal_reference_number], unique: true, name: 'idx_internal_client_ref_per_psych'

  end
end
