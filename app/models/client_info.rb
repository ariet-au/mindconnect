class ClientInfo < ApplicationRecord
  belongs_to :psychologist_profile
  has_many :client_contacts, dependent: :destroy
  has_many :bookings, dependent: :nullify
  after_create :notify_psychologist

  accepts_nested_attributes_for :client_contacts, allow_destroy: true, reject_if: :all_blank

  validates :first_name, presence: true


  enum :submitted_by, { client: "client", psychologist: "psychologist" }

  enum :status, {
    inquiry: 0,                # submitted by unknown client
    referred: 1,               # submitted by psychologist / known client
    booked: 2,                 # booking created
    confirmed_booking: 3,      # booking confirmed
    active_upcoming: 4,        # active with sessions coming up
    active_no_upcoming: 5,     # active but no upcoming sessions
    inactive: 6                # previously active, now inactive
  }

  def full_name
    "#{first_name} #{last_name}" # or however you want it displayed
  end 


  private
  
  def notify_psychologist
    # Get the User object for the psychologist
    psychologist_user = psychologist_profile.user
    return unless psychologist_user&.telegram_chat_id.present?

    # Send the notification asynchronously via your job
    TelegramNotifierJob.perform_later(
      psychologist_user.telegram_chat_id,
      "📥 New client info submitted by #{full_name}."
    )
  end
end
