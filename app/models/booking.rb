class Booking < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :service, optional: true
  belongs_to :client_profile, optional: true
  belongs_to :internal_client_profile, optional: true
  belongs_to :client_info, optional: true
  accepts_nested_attributes_for :client_info, allow_destroy: true, reject_if: :all_blank

  before_create :generate_confirmation_token

  after_create :notify_psychologist


  enum :status, {
    pending: 'pending',
    confirmed: 'confirmed',
    declined: 'declined',
    cancelled: 'cancelled'
  } , default: :pending
  #attribute :status, :string, default: 'pending'


  validates :start_time, :end_time, :status, presence: true
  validate :at_least_one_client_present
  validates :psychologist_profile_id, presence: true
  validates :created_by, inclusion: { in: %w[psychologist client] }, allow_nil: false # Enforce created_by

  before_validation :set_end_time, if: :start_time_changed?
  validate :end_time_after_start_time

  private

  def at_least_one_client_present
    unless client_profile_id.present? || client_info_id.present? || client_info.present?
      errors.add(:base, "At least one client (client_profile or internal_client_profile) must be selected")
    end
  end

  
  def set_end_time
    if service.present? && start_time.present?
      self.end_time = start_time + service.duration_minutes.minutes
    elsif start_time.present?
      self.end_time = start_time + 1.hour # Fallback if service is nil (adjust as needed)
    end
  end

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "must be after the start time") if end_time <= start_time
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end

  def notify_psychologist
    psychologist_user = psychologist_profile.user
    return unless psychologist_user&.telegram_chat_id.present?

    # Default to Rails timezone if none set
    tz = psychologist_profile.time_zone.presence || Time.zone.name

    formatted_time = start_time.in_time_zone(tz).strftime("%d %b %Y at %H:%M")

    TelegramNotifierJob.perform_later(
      psychologist_user.telegram_chat_id,
      "📅 New booking scheduled for #{formatted_time}.\n" \
      "Client: #{client_info&.full_name || client_profile&.full_name || 'Unknown'}"
    )
  end

  # Helper to show client name
  def client_display_name
    if client_profile.present?
      client_profile.full_name
    elsif internal_client_profile.present?
      internal_client_profile.full_name
    elsif client_info.present?
      client_info.full_name
    else
      "Unknown client"
    end
  end

end

