class AddVerificationToEducations < ActiveRecord::Migration[8.0]
  def change
    add_column :educations, :verification_status, :integer , default: 0, null: false
    add_column :educations, :verified_by_id, :bigint
    add_column :educations, :verified_at, :datetime
    add_column :educations, :verification_notes, :text
    add_column :educations, :verified_source, :string
    add_column :educations, :publicly_visible, :boolean, default: true
  end
end
