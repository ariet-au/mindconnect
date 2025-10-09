class EventRegistration < ApplicationRecord
  belongs_to :event, counter_cache: :registrations_count
  belongs_to :user, optional: true
  belongs_to :client_info, optional: true
  accepts_nested_attributes_for :client_info, allow_destroy: true, reject_if: :all_blank

  enum :status, {
    pending: 0,             # just registered, not approved yet
    approved: 1,            # registration approved
    cancelled: 2,           # registration cancelled
    declined: 3,
    waitlisted: 4,          # event full, on waitlist
    attended: 5,            # actually attended the event
    no_show: 6,             # registered but did not attend
    event_cancelled: 7 
  }
  validates :event, presence: true
  validates :user, uniqueness: { scope: :event_id, message: "can only register once per event" }, if: -> { user.present? }
  validate :user_or_client_info_present
  validate :price_non_negative

  def user_or_client_info_present
    if user.nil? && client_info.nil?
      errors.add(:base, "Must have either a user or client info")
    end
  end

  def price_non_negative
    if price.present? && price < 0
      errors.add(:price, "cannot be negative")
    end
  end

  def paid?
    paid_at.present?
  end
end