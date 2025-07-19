# app/models/psychologist_profile.rb

# This class defines the model for psychologist profiles.
# It belongs to a User and has an enumeration for gender.
class PsychologistProfile < ApplicationRecord
  include PgSearch::Model



  belongs_to :user
  has_one_attached :profile_img
  has_many :internal_client_profiles, dependent: :destroy # Add this line


  #specialities 
  has_many :psychologist_specialties, dependent: :destroy
  has_many :specialties, through: :psychologist_specialties

  #client types
  has_many :psychologist_client_types, dependent: :destroy
  has_many :client_types, through: :psychologist_client_types
  
  #issues
  has_many :psychologist_issues, dependent: :destroy
  has_many :issues, through: :psychologist_issues

  has_many :services, through: :user

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


  scope :verified, -> { joins(:user).where.not(users: { confirmed_at: nil }) }
  #monetize :standard_rate, as: :standard_rate_money, with_model_currency: :currency ,allow_nil: true , as_subunit: false
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
  validates :profile_url, uniqueness: true, allow_blank: true,
            format: { with: /\A[a-z0-9\-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }

pg_search_scope :search_full_text,
  against: [:first_name, :last_name, :about_me, :education, :license_number, :city, :country],
  associated_against: {
    services: [:name, :description]
  },
  using: {
    tsearch: { prefix: true }
  }

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


  
  private 
  def slugify_profile_url
      if profile_url.present?
        self.profile_url = profile_url.downcase.strip
                                      .gsub(/[^a-z0-9\s-]/, "")  
                                      .gsub(/\s+/, "-")          
                                      .gsub(/-+/, "-")           
      end
  end



end