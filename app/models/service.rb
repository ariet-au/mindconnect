class Service < ApplicationRecord
  belongs_to :user
  
  
 # monetize :price, as: :price_money,  with_model_currency: :currency ,allow_nil: true, as_subunit: false

monetize :price, as: :price_money, 
         with_model_currency: :currency, 
         allow_nil: true, 
         numericality: { greater_than_or_equal_to: 0 }

  enum :delivery_method, { in_person: 0, online: 1, phone: 2 }


unless defined?(ActiveRecord::Base)
    attr_accessor :price_cents, :currency, :price_money

    def initialize(price_amount, currency_code)
      @price_cents = (price_amount * 100).to_i
      @currency = currency_code.upcase
      @price_money = Money.new(@price_cents, @currency)
    end
  end


  # This method converts the price_money from its current currency to the target_currency.
  # It leverages the ExchangeRateService to perform the actual rate calculation and conversion.
  # def converted_rate(target_currency)
  #   # Log information for debugging (consider using Rails.logger.debug in production)
  #   Rails.logger.info "=== Converting from #{currency} to #{target_currency} ==="
  #   Rails.logger.info "Original price_money: #{price_money}"

  #   # If the target currency is the same as the original, no conversion is needed.
  #   return price_money if currency.upcase == target_currency.upcase

  #   # Use the ExchangeRateService.convert method directly.
  #   # It handles fetching rates and performing the conversion.
  #   # price_money.to_f converts the Money object to a float representation of its amount.
  #   converted_amount_float = ExchangeRateService.convert(
  #     price_money.to_f,
  #     from: currency.upcase,
  #     to: target_currency.upcase
  #   )

  #   if converted_amount_float
  #     # The Money gem typically stores amounts in cents (integer).
  #     # Convert the float amount back to cents for the new Money object.
  #     converted_cents = (converted_amount_float * 100).to_i
  #     result = Money.new(converted_cents, target_currency.upcase)
  #     Rails.logger.info "Final result: #{result.inspect}"
  #     result
  #   else
  #     # If conversion fails (e.g., no rate found, API error), return the original price_money
  #     # as a fallback, and log the reason.
  #     Rails.logger.warn "Conversion failed for #{currency} to #{target_currency}. Returning original price_money."
  #     price_money
  #   end
  # end



  def converted_rate(target_currency)
    target_currency = target_currency.upcase

    if currency == target_currency
      return Money.new((price * 100).round, currency)
    end

    amount = price.to_f
    rate = ExchangeRateService.convert(amount, from: currency, to: target_currency)

    Rails.logger.debug "Converting #{amount} from #{currency} to #{target_currency} at rate #{rate.inspect}"

    return Money.new((price * 100).round, currency) if rate.nil?

    Money.new((rate * 100).round, target_currency)
  end

end
