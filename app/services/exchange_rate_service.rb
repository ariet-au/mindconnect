require 'net/http'
require 'json'
require 'ostruct' # For OpenStruct used in Rails stub

# Ensure Rails and its components are available or stubbed if running outside Rails.
# This block provides basic stub implementations for Rails components
# (cache, logger, credentials) to allow the service to run in isolation for testing.
unless defined?(Rails)
  class Rails
    def self.cache
      @cache ||= (require 'active_support/cache/memory_store'; ActiveSupport::Cache::MemoryStore.new)
    end

    def self.logger
      @logger ||= (require 'logger'; Logger.new($stdout))
    end

    def self.application
      # IMPORTANT: In a real Rails application, ensure your API key is securely stored
      # in Rails credentials (config/credentials.yml.enc) and accessed like this:
      # Rails.application.credentials.fixer_api_key
      # For local development or testing outside Rails, you might use an environment variable:
      # ENV['FIXER_API_KEY']
      @application ||= OpenStruct.new(credentials: OpenStruct.new(fixer_api_key: ENV['FIXER_API_KEY'] || 'YOUR_FALLBACK_API_KEY'))
    end
  end

  unless defined?(ActiveSupport)
    module ActiveSupport
      module Cache
        class MemoryStore
          def initialize
            @data = {}
            @expirations = {}
          end

          def fetch(key, options = {})
            expires_in = options[:expires_in]
            if @data.key?(key) && !expired?(key)
              return @data[key]
            end

            value = yield
            @data[key] = value
            @expirations[key] = Time.now + expires_in if expires_in
            value
          end

          private
          def expired?(key)
            @expirations[key] && @expirations[key] < Time.now
          end
        end
      end
    end
    # Ensure 'money' gem is available for the Money.new calls
    # For a full Rails app, you'd typically have `gem 'money'` in your Gemfile
    # and it would be loaded automatically.
    unless defined?(Money)
      class Money
        attr_reader :cents, :currency

        def initialize(cents, currency)
          @cents = cents
          @currency = currency
        end

        def to_f
          @cents / 100.0
        end

        def inspect
          "#<Money amount=#{to_f} currency=#{currency}>"
        end
      end
    end
  end
end


class ExchangeRateService
  API_BASE_URL = 'https://data.fixer.io/api'
  API_KEY = Rails.application.credentials.fixer_api_key # Accesses the API key from Rails credentials or stub

  # Converts a given amount from one currency to another.
  # Returns the converted amount as a float, or nil if conversion fails.
  def self.convert(amount, from:, to:)
    from = from.upcase
    to = to.upcase

    return amount if from == to # No conversion needed if currencies are the same

    rate = get_conversion_rate(from: from, to: to)
    if rate
      (amount * rate).round(4) # Round to 4 decimal places for precision
    else
      Rails.logger.error "ExchangeRateService: Failed to get conversion rate from #{from} to #{to}."
      nil # Indicate failure
    end
  end

  # Fetches exchange rates relative to EUR.
  # If 'to' is specified, fetches rates for those specific currencies.
  # If 'to' is nil, fetches all available rates relative to EUR.
  # This method is primarily used internally by other service methods.
  def self.get_rates(to: nil)
    fetch_rates(to: to)
  end

  private

  # Determines the conversion rate between two currencies.
  # Fixer.io uses EUR as the base currency.
  # - If 'from' is EUR, it directly fetches the rate to 'to'.
  # - If 'from' is not EUR, it calculates the cross-currency rate using EUR as an intermediary.
  def self.get_conversion_rate(from:, to:)
    Rails.cache.fetch("fx_rate_#{from}_#{to}", expires_in: 1.day) do
      if from == 'EUR'
        rate = fetch_single_rate(to: to)
        Rails.logger.debug "ExchangeRateService: Direct EUR to #{to} rate: #{rate}"
        rate
      else
        all_eur_rates = fetch_all_rates # <-- now returns valid rates hash

        from_rate_vs_eur = all_eur_rates[from.upcase]
        to_rate_vs_eur = all_eur_rates[to.upcase]

        if from_rate_vs_eur && to_rate_vs_eur
          if from_rate_vs_eur == 0
            Rails.logger.error "ExchangeRateService: Cannot convert from #{from} as its EUR rate is zero (division by zero risk)."
            nil
          else
            calculated_rate = to_rate_vs_eur / from_rate_vs_eur
            Rails.logger.debug "ExchangeRateService: Calculated cross-rate for #{from} to #{to}: #{calculated_rate}"
            calculated_rate
          end
        else
          Rails.logger.error "ExchangeRateService: Missing EUR rate for #{from} or #{to}. From rate: #{from_rate_vs_eur}, To rate: #{to_rate_vs_eur}. Cannot calculate cross-rate."
          nil
        end
      end
    end
  end

  # Fetches a single exchange rate for a specific target currency relative to EUR.
  def self.fetch_single_rate(to:)
    rates = fetch_rates(to: to)
    rates[to] if rates.is_a?(Hash) # Ensure rates is a hash before accessing
  end

  # Fetches all available exchange rates relative to EUR.
  def self.fetch_all_rates
    # Explicitly request the currencies you want rates for
    fetch_rates(to: ['EUR', 'USD', 'KZT', 'KGS','UZS','RUB','TJS','GBP'])
  end

  # Core method to make the API call to Fixer.io and cache the results.
  # 'to' can be a single currency string, an array of currency strings, or nil for all rates.
  def self.fetch_rates(to: nil)
    # Ensure currency symbols are uppercase strings and unique
    symbols_array = Array(to).map(&:to_s).map(&:upcase).compact.uniq
    symbols_param = symbols_array.empty? ? nil : symbols_array.join(',')

    # Create a cache key based on whether specific symbols are requested or all rates
    cache_key = symbols_param ? "fx_rates_#{symbols_param}" : "fx_all_rates"

    # Fetch from cache or make API call if not cached or expired (expires in 1 day)
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      params = { access_key: API_KEY }
      params[:symbols] = symbols_param if symbols_param # Add symbols parameter if specified

      begin
        url = URI("#{API_BASE_URL}/latest?#{URI.encode_www_form(params)}")
        response = Net::HTTP.get_response(url)

        if response.is_a?(Net::HTTPSuccess)
          data = JSON.parse(response.body)
          if data['success']
            data['rates'] || {} # Return the 'rates' hash, or an empty hash if not present
          else
            # Log specific Fixer API errors
            error_info = data.is_a?(Hash) && data['error'].is_a?(Hash) ? data['error']['info'] : 'Unknown Fixer API error structure'
            Rails.logger.error "Fixer API Error: #{error_info} for symbols: #{symbols_param || 'all'}"
            {} # Return empty hash on API error
          end
        else
          # Log HTTP errors (e.g., 404, 500)
          Rails.logger.error "API HTTP Error #{response.code}: #{response.message} for URL: #{url}"
          {} # Return empty hash on HTTP error
        end
      rescue JSON::ParserError => e
        # Handle cases where the API response is not valid JSON
        Rails.logger.error "ExchangeRateService JSON Parsing Error: #{e.message}"
        {}
      rescue StandardError => e
        # Catch any other unexpected errors during the API call
        Rails.logger.error "ExchangeRateService StandardError: #{e.message} | Backtrace: #{e.backtrace.first(5).join("\n")}"
        {}
      end
    end
  end
end
