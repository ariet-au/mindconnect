# app/models/psychologist_profile.rb

# This class defines the model for psychologist profiles.
# It belongs to a User and has an enumeration for gender.
class PsychologistProfile < ApplicationRecord
  include PgSearch::Model

  before_validation :set_default_primary_contact_method, on: :create
  before_save :normalize_socials




  belongs_to :user
 # belongs_to :user_for_search, class_name: 'User', foreign_key: 'user_id'

  has_many :services, through: :user
  belongs_to :featured_service, class_name: 'Service', optional: true


  has_one_attached :profile_img
  has_many :internal_client_profiles, dependent: :destroy # Add this line

  has_many :client_infos, dependent: :destroy

  #specialities 
  has_many :psychologist_specialties, dependent: :destroy
  has_many :specialties, through: :psychologist_specialties

  #client types
  has_many :psychologist_client_types, dependent: :destroy
  has_many :client_types, through: :psychologist_client_types
  
  #issues
  has_many :psychologist_issues, dependent: :destroy
  has_many :issues, through: :psychologist_issues 

  

  has_many :psychologist_languages
  has_many :languages, through: :psychologist_languages


  has_many  :educations, dependent: :destroy
  #accepts_nested_attributes_for :educations, allow_destroy: true
  accepts_nested_attributes_for :educations, allow_destroy: true, reject_if: :all_blank


  #bookings
    # Add this line:
  has_many :psychologist_availabilities, dependent: :destroy
  

  # You probably also want:
  has_many :psychologist_unavailabilities, dependent: :destroy

  has_many :bookings

  has_many :articles, dependent: :destroy


  # Scopes for filtering profiles
  scope :confirmed, -> { where(user_id: User.where.not(confirmed_at: nil).select(:id)) }  
  scope :active, -> { where(user_id: User.where('last_sign_in_at >= ?', 1.month.ago).select(:id)) }
  scope :filled, -> {
    where.not(first_name: [nil, ''], last_name: [nil, ''], about_me: [nil, ''])
    .where("standard_rate IS NOT NULL AND standard_rate != 0")
  }
  scope :not_hidden, -> { where(hidden: [false, nil]) }

  monetize :standard_rate, as: :standard_rate_money, 
         with_model_currency: :currency, 
         allow_nil: true, 
         numericality: { greater_than_or_equal_to: 0 }
         
  enum :gender, {
    unspecified: 0, 
    male: 1,       
    female: 2,      
    other: 3      
  }

   enum :status, {
    pending_review: "pending_review",
    published: "approved",
    suspended: "suspended",
    archived: "archived"
  }

  VALID_YOUTUBE_REGEX = %r{
    \A
    (https?:\/\/)?                                   # optional http or https
    (www\.)?                                          # optional www
    (youtube\.com\/watch\?v=|youtu\.be\/)            # required domain and path
    [\w\-]{11}                                        # exactly 11-char video ID
    (&.*)?                                            # optional query params
    \z
  }x



  before_validation :strip_youtube_url
  validates :youtube_video_url,
    format: {
      with: VALID_YOUTUBE_REGEX,
      message: "must be a valid YouTube URL"
    },
    allow_blank: true


# URL 
  before_validation :slugify_profile_url
  validates :profile_url,
          uniqueness: true,
          allow_nil: true,            # allow NULL
          length: { in: 3..30, message: "must be between 3 and 30 characters" },
          format: {
            with: /\A[a-z0-9\-_]+\z/,
            message: "can only contain lowercase letters, numbers, hyphens, and underscores"
          },
          if: -> { profile_url.present? } # only validate format/length if not nil


pg_search_scope :search_full_text,
  against: [:first_name, :last_name, :about_me, :religion, :about_clients, :about_issues, :about_specialties],
  associated_against: {
    services: [:name, :description],
    issues: [:name],
    specialties: [:name]
  },
  using: {
    tsearch: { prefix: true }, # finds partial words
    trigram: { threshold: 0.2 } # finds fuzzy matches (typos, similar words)
  },
  ranked_by: ":tsearch + :trigram" # rank by combined score
  
  
  def full_name
      "#{first_name} #{last_name}" # or however you want it displayed
  end

  def strip_youtube_url
      self.youtube_video_url = youtube_video_url.strip.presence if youtube_video_url.present?
  end

  def resize_profile_image
    return unless profile_image.attached?

    resized = ImageProcessing::MiniMagick
      .source(profile_image.download)
      .resize_to_limit(400, 400) # or use resize_to_fit / fill, depending on desired effect
      .call

    profile_image.attach(
      io: StringIO.new(resized.read),
      filename: "resized_#{profile_image.filename}",
      content_type: profile_image.content_type
    )
  end
  # For demonstration purposes outside a full ActiveRecord context,
  # we'll add a simple initializer and accessors. In a real Rails app
  # with ActiveRecord, these would be handled by the ORM and `monetize`.
  unless defined?(ActiveRecord::Base)
    # When monetizing a decimal column directly, money-rails still internally
    # works with cents, so we'll simulate that for our stub.
    attr_accessor :standard_rate, :currency, :standard_rate_money

    def initialize(rate_amount, currency_code)
      @standard_rate = rate_amount # Store the decimal amount
      @currency = currency_code.upcase
      # Money.new expects cents, so convert the decimal amount to cents here.
      @standard_rate_money = Money.new((rate_amount * 100).to_i, @currency)
    end
  end

  # next avail slot
  def available_at?(datetime)
    datetime = datetime.in_time_zone(timezone)
    day_of_week = datetime.wday
    time_of_day = datetime.strftime('%H:%M:%S')

    # Check regular availability
    available_today = availabilities.where(day_of_week: day_of_week)
                                  .where("? BETWEEN start_time_of_day AND end_time_of_day", time_of_day)
                                  .exists?

    # Check unavailabilities
    unavailable = unavailabilities.where(
      "(recurring = true AND day_of_week = ? AND (recurring_until IS NULL OR recurring_until >= ?)) OR
      (recurring = false AND (start_time, end_time) OVERLAPS (?, ?))",
      day_of_week,
      datetime.to_date,
      datetime,
      datetime
    ).exists?

    available_today && !unavailable
  end

  # This method converts the standard_rate_money from its current currency to the target_currency.
  # It leverages the ExchangeRateService to perform the actual rate calculation and conversion.
  def converted_rate(target_currency)
    target_currency = target_currency.upcase

    if currency == target_currency
      return Money.new((standard_rate * 100).round, currency)
    end

    amount = standard_rate.to_f
    rate = ExchangeRateService.convert(amount, from: currency, to: target_currency)

    Rails.logger.debug "Converting #{amount} from #{currency} to #{target_currency} at rate #{rate.inspect}"

    return Money.new((standard_rate * 100).round, currency) if rate.nil?

    Money.new((rate * 100).round, target_currency)
  end
  # app/models/psychologist_profile.rb
def next_available_slot
  # Get the first service (or use your own availability logic)
  service = services.first # simplest version
  
  return nil unless service.present?

  slot_finder = TimezoneAwareSlotFinder.new(
    id,
    service.duration_minutes,
    timezone.presence || 'UTC'
  )
  
  slot_finder.next_available_slot(Time.current)
end


  
  private 

  def normalize_socials
    normalize_instagram
    normalize_telegram
  end

  def normalize_instagram
    return if instagram.blank?

    self.instagram = instagram.strip
                              .sub(/^https?:\/\/(www\.)?instagram\.com\//i, "") # remove domain
                              .sub(/^www\./i, "")                               # remove www
                              .sub(/\/$/, "")                                   # remove trailing slash
                              .sub(/^@/, "")                                    # remove @
  end

  def normalize_telegram
    return if telegram.blank?

    self.telegram = telegram.strip
                             .sub(/^https?:\/\/(www\.)?t\.me\//i, "") # remove t.me link
                             .sub(/^@/, "")                           # remove @
                             .sub(/\/$/, "")                          # remove trailing slash
  end
  
  def slugify_profile_url
    if profile_url.present?
      self.profile_url = profile_url.downcase.strip
                                    .gsub(/[^a-z0-9\s_-]/, "")
                                    .gsub(/\s+/, "-")
                                    .gsub(/-+/, "-")
    else
      self.profile_url = nil  # convert empty string to NULL
    end
  end

  def set_default_primary_contact_method
    return if primary_contact_method.present? # respect user choice

    self.primary_contact_method =
      if telegram.present?
        "telegram"
      elsif whatsapp.present?
        "whatsapp"
      else
        "email"
      end
  end



end