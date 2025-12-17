class PsychologistProfileReport < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :reporter_user, class_name: 'User', optional: true

  enum :reason, {
    fake_profile: 0,
    inappropriate_content: 1,
    harassment: 2,
    scam: 3,
    other: 4
  }

  enum :status, {
    pending: 0,
    reviewed: 1,
    dismissed: 2,
    action_taken: 3
  }

  validates :reason, presence: true
  validate :exactly_one_contact_method

  private

  def exactly_one_contact_method
    identifiers = [
      reporter_user_id.present?,
      reporter_phone.present?,
      reporter_email.present?
    ]

    if identifiers.count(true) != 1
      errors.add(
        :base,
        "Provide exactly one contact method (user, phone, or email)"
      )
    end
  end
end
