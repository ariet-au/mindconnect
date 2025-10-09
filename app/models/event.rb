class Event < ApplicationRecord
  belongs_to :psychologist_profile
  has_many :event_registrations, dependent: :destroy
  has_many :users, through: :event_registrations
  has_many :client_infos, through: :event_registrations



    monetize :price, as: :price_money, 
         with_model_currency: :currency, 
         allow_nil: true, 
         numericality: { greater_than_or_equal_to: 0 }


  # ---------- ENUMS ----------
  enum :audience, { everyone: 0, clients_only: 1, psychologists_only: 2 }
  enum :access_type, { open: 0, invite_only: 1, approval_or_invite: 2 }
  enum :visibility, { visible: 0, hidden: 1, archived: 2 }
  enum :status, { draft: 0, upcoming: 1, ongoing: 2, completed: 3, cancelled: 4 }
  # ---------- VALIDATIONS ----------
  validates :title, presence: true, length: { maximum: 200 }
  validates :start_time, :end_time, presence: true
  validate :end_after_start
  validates :capacity, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  # ---------- SCOPES ----------
  scope :upcoming, -> { where("start_time > ?", Time.current).where(archived_at: nil) }
  scope :past, -> { where("end_time < ?", Time.current) }
  scope :visible_to_public, -> { where(visibility: :visible) }

  # ---------- CALLBACKS ----------
  before_save :set_default_timezone

  # ---------- INSTANCE METHODS ----------
  def archived?
    archived_at.present?
  end

  def registration_open?
    return false if registration_ends_at.present? && registration_ends_at < Time.current
    return false if capacity.present? && registrations_count >= capacity
    true
  end

  def online?
    online
  end

  def location_visible?(user_or_client)
    return true unless hide_details_until_approved
    return false if user_or_client.nil?

    # only show details if user/client is approved
    registration = event_registrations.find_by(user: user_or_client) ||
                   event_registrations.find_by(client_info: user_or_client)
    registration&.approved?
  end

  private

  def end_after_start
    return if end_time.blank? || start_time.blank?
    if end_time < start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  def set_default_timezone
    self.timezone ||= "Asia/Bishkek"
  end
end
