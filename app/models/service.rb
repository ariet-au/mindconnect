class Service < ApplicationRecord
  belongs_to :user
  after_create :set_as_featured_if_first

  enum :status, { active: 0, archived: 1 }

  scope :active_only, -> { where(status: :active, archived_at: nil) }
  scope :archived, -> { where(status: :archived).or(where.not(archived_at: nil)) }

  
 # monetize :price, as: :price_money,  with_model_currency: :currency ,allow_nil: true, as_subunit: false

  monetize :price, as: :price_money, 
         with_model_currency: :currency, 
         allow_nil: true, 
         numericality: { greater_than_or_equal_to: 0 }

  enum :delivery_method, { in_person: 0, online: 1, phone: 2 }

  validates :duration_minutes,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 10,
              less_than_or_equal_to: 180
            }
            
  unless defined?(ActiveRecord::Base)
    attr_accessor :price_cents, :currency, :price_money

    def initialize(price_amount, currency_code)
      @price_cents = (price_amount * 100).to_i
      @currency = currency_code.upcase
      @price_money = Money.new(@price_cents, @currency)
    end
  end

  def archive!
    update!(status: :archived, archived_at: Time.current)
  end

  def unarchive!
    update!(status: :active, archived_at: nil)
  end

  def archived?
    status == "archived" || archived_at.present?
  end


  def name_with_duration
    "#{name} (#{duration_minutes} mins)"
  end

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

  private

  def set_as_featured_if_first
    profile = user.psychologist_profile
    return unless profile.present? && profile.featured_service_id.blank?

    profile.update(featured_service_id: id)
  end

end
