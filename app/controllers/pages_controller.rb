class PagesController < ApplicationController

  include LocationDetectable

  def home
    # Group by city (exclude blank)
    @cities = PsychologistProfile
    .where(hidden: false)
    .group(:city)
    .order("count_all DESC")
    .count

    @psychologist_profiles = PsychologistProfile.confirmed.filled.active.with_profile_img.not_hidden.order(updated_at: :desc).limit(5)

    @quizzes = Quiz.limit(4)
      # Count those who offer online sessions
      @online_count = PsychologistProfile.where(online: true).count

      # Issues — since you don’t have an Issue model, we’ll just extract keywords from text for now
      # Later, you can replace this with a real "issues" association.
      @popular_issues = Issue.joins(:psychologist_profiles)
                              .group(:id, :name)
                              .order('COUNT(psychologist_profiles.id) DESC')
                              .limit(10)
                              .select('issues.*, COUNT(psychologist_profiles.id) AS psychologists_count')

      # Price range — use standard_rate

      session[:currency] = params[:currency] if params[:currency].present?
      @selected_currency = current_currency.upcase

      # Convert all rates to the selected currency
      converted_rates = PsychologistProfile
                          .where.not(standard_rate: nil)
                          .map { |p| p.converted_rate(@selected_currency)&.to_f }
                          .compact

      @min_price = converted_rates.min || 0
      @max_price = converted_rates.max || 0


      unless @current_city
        ip = request.remote_ip
        begin
          res = Net::HTTP.get(URI("https://ipinfo.io/#{ip}/json"))
          geo = JSON.parse(res)
          @current_city = geo["city"] && geo["country"] ? "#{geo['city']}, #{geo['country']}" : nil
        rescue
          @current_city = nil
        end
      end

      # Load countries + cities for autocomplete
      @countries_with_cities = get_countries_with_cities_data
  end 

  def about_for_psych
  end

  def about_for_clients
  end

  def contact
  end

  def how_to
  end 

  private

  def get_countries_with_cities_data
    data = YAML.load_file(Rails.root.join("config/countries_cities.yml"))

    data.map do |country|
      {
        "name" => country["name"],
        "translated_name" => I18n.t("countries.#{country['name'].parameterize(separator: '_')}", default: country["name"]),
        "cities" => country["cities"].map do |city|
          {
            "name" => city,
            "translated_name" => I18n.t("cities.#{city.parameterize(separator: '_')}", default: city)
          }
        end
      }
    end
  end
end
