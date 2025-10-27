# config/initializers/location_aliases.rb
LOCATION_NAME_MAP = YAML.load_file(Rails.root.join('config', 'location_name_map.yml'))
