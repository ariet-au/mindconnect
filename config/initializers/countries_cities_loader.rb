# # config/initializers/countries_cities_loader.rb

require 'yaml'

raw_data = YAML.load_file(Rails.root.join('config', 'countries_cities.yml'))

COUNTRIES_AND_CITIES = raw_data.map do |country|
  {
    name: country['name'].strip.downcase,
    cities: Array(country['cities']).map { |c| c.strip.downcase }.sort
  }
end.freeze

# Helper: quick lookup hashes
COUNTRY_NAMES = COUNTRIES_AND_CITIES.map { |c| c[:name] }
CITY_LOOKUP = COUNTRIES_AND_CITIES.each_with_object({}) do |country, h|
  country[:cities].each { |city| h[city] = country[:name] }
end
