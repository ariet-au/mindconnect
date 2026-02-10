class Education < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :verified_by, class_name: "User", optional: true

  # Verification status enum
  enum :verification_status, {
    unverified: 0,
    pending_review: 1,
    verified: 2,
    rejected: 3
  }

  # Optional proof attachment if you want to store a degree scan
  has_many_attached :proof_documents

  # Validationsch
  #validates :degree, :field_of_study, presence: true
  with_options if: :any_field_present? do
    validates :degree, presence: true
    validates :field_of_study, presence: true
  end

  # Scopes
  scope :verified, -> { where(verification_status: :verified) }
  scope :pending, -> { where(verification_status: :pending_review) }
  scope :publicly_visible, -> { where(publicly_visible: true) }

  # Convenience method to mark as verified
  def mark_verified(by_user, source: nil, notes: nil)
    self.verification_status = :verified
    self.verified_by = by_user
    self.verified_at = Time.current
    self.verified_source = source if source
    self.verification_notes = notes if notes
    save
  end
  
  private
  
  def any_field_present?
    degree.present? ||
    field_of_study.present? ||
    institution.present? ||
    start_year.present? ||
    end_year.present?
  end
end
