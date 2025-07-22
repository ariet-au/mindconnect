# config/initializers/countries_cities_loader.rb
require 'yaml'

# Load the YAML file
# Using ||= ensures it's only loaded once
Rails.application.config.countries_and_cities = YAML.load_file(Rails.root.join('config', 'countries_cities.yml'))

# You might want to add some basic validation or formatting here
# For example, ensuring cities are sorted within each country
Rails.application.config.countries_and_cities.each do |country_data|
  country_data['cities'].sort! if country_data['cities'].is_a?(Array)
end