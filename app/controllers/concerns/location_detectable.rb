# frozen_string_literal: true

module LocationDetectable
  extend ActiveSupport::Concern

  included do
    before_action :set_location
  end

  private

  def set_location
    ip = request.remote_ip
    location = LocationDetector.detect(ip: ip) # uses LOCATION_NAME_MAP internally

    # Combine city and country for the single input field
    if location[:city].present? && location[:country].present?
      @current_city = "#{location[:city]}, #{location[:country]}"
    elsif location[:city].present?
      @current_city = location[:city]
    elsif location[:country].present?
      @current_city = location[:country]
    else
      @current_city = nil
    end
  end
end
