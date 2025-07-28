class Booking < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :service, optional: true
  belongs_to :client_profile, optional: true
  belongs_to :internal_client_profile, optional: true

  before_create :generate_confirmation_token

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
    if client_profile.nil? && internal_client_profile.nil?
      errors.add(:base, "Either client_profile or internal_client_profile must be present")
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
end

# class Booking < ApplicationRecord
#   belongs_to :psychologist_profile
#   belongs_to :service , optional: true
#   belongs_to :client_profile, optional: true
#   belongs_to :internal_client_profile, optional: true

#   before_create :generate_confirmation_token

#   enum status: {
#     pending: 'pending',     # Awaiting confirmation from the other party
#     confirmed: 'confirmed', # Both parties have agreed
#     declined: 'declined',   # One party declined the booking
#     cancelled: 'cancelled'  # Booking was cancelled
#   }, _default: 'pending'

#   validates :start_time, :end_time, :status, presence: true
#   validate :at_least_one_client_present
#   validates :psychologist_profile_id, presence: true
#   validates :created_by, inclusion: { in: %w[psychologist client], message: 'must be either "psychologist" or "client"' }, allow_nil: true
  
#   before_validation :set_end_time, if: :start_time_changed?

#   validate :end_time_after_start_time

#   # VALID_STATUSES = ['pending', 'confirmed', 'cancelled', 'completed'].freeze
#   # validates :status, inclusion: { in: VALID_STATUSES }





#   def at_least_one_client_present
#     if client_profile.nil? && internal_client_profile.nil?
#       errors.add(:base, "Either client_profile or internal_client_profile must be present")
#     end
#   end

#   private

#   def set_end_time
#     if service.present? && start_time.present?
#       self.end_time = start_time + service.duration_minutes.minutes
#     else
#       self.end_time = nil # Or handle appropriately if not present
#     end
#   end

#   def end_time_after_start_time
#     return if end_time.blank? || start_time.blank?

#     if end_time <= start_time
#       errors.add(:end_time, "must be after the start time")
#     end
#   end

#   def generate_confirmation_token
#     self.confirmation_token = SecureRandom.urlsafe_base64
#   end

#   def set_default_status
#     self.status ||= 'pending' if self.status.blank?
#   end
# end

