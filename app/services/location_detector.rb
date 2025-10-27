class LocationDetector
  def self.detect(ip:)
    result = Geocoder.search(ip).first
    return {} unless result

    raw_city = result.city&.downcase
    raw_country = result.country&.downcase || result.country_code&.downcase

    mapped_city = LOCATION_NAME_MAP.dig('city_aliases', raw_city) || raw_city
    mapped_country = LOCATION_NAME_MAP.dig('country_aliases', raw_country) || raw_country

    { city: mapped_city&.titleize, country: mapped_country&.titleize }
  end
end
