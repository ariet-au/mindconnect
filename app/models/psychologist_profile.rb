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



  #bookings
    # Add this line:
  has_many :psychologist_availabilities, dependent: :destroy

  # You probably also want:
  has_many :psychologist_unavailabilities, dependent: :destroy

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

pg_search_scope :search_full_text,
  against: [:first_name, :last_name, :about_me, :education, :license_number, :city, :country],
  associated_against: {
    services: [:name, :description]
  },
  using: {
    tsearch: { prefix: true }
  }


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




end