# app/models/psychologist_profile.rb

# This class defines the model for psychologist profiles.
# It belongs to a User and has an enumeration for gender.
class PsychologistProfile < ApplicationRecord
  belongs_to :user
  has_one_attached :profile_img

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

  monetize :standard_rate, as: :standard_rate_money, with_model_currency: :currency , as_subunit: false

  enum :gender, {
    unspecified: 0, 
    male: 1,       
    female: 2,      
    other: 3      
  }

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
    # Log information for debugging (consider using Rails.logger.debug in production)
    Rails.logger.info "=== Converting from #{currency} to #{target_currency} ==="
    Rails.logger.info "Original standard_rate_money: #{standard_rate_money}"

    # If the target currency is the same as the original, no conversion is needed.
    return standard_rate_money if currency.upcase == target_currency.upcase

    # Use the ExchangeRateService.convert method directly.
    # It handles fetching rates and performing the conversion.
    # standard_rate_money.to_f converts the Money object to a float representation of its amount.
    converted_amount_float = ExchangeRateService.convert(
      standard_rate_money.to_f,
      from: currency.upcase,
      to: target_currency.upcase
    )

    if converted_amount_float
      # The Money gem typically stores amounts in cents (integer).
      # Convert the float amount back to cents for the new Money object.
      converted_cents = (converted_amount_float * 100).to_i
      result = Money.new(converted_cents, target_currency.upcase)
      Rails.logger.info "Final result: #{result.inspect}"
      result
    else
      # If conversion fails (e.g., no rate found, API error), return the original standard_rate_money
      # as a fallback, and log the reason.
      Rails.logger.warn "Conversion failed for #{currency} to #{target_currency}. Returning original standard_rate_money."
      standard_rate_money
    end
  end




end