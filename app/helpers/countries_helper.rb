module CountriesHelper
  def country_list
    [
      ['Kyrgyzstan', 'KG'],
      ['Kazakhstan', 'KZ'],
      ['Uzbekistan', 'UZ'],
      # Add more countries as needed
    ].sort_by { |c| c[0] }
  end
end