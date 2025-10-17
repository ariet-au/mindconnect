class PagesController < ApplicationController
  def home
    # Group by city (exclude blank)
   @cities = PsychologistProfile
  .where(hidden: false)
  .group(:city)
  .order("count_all DESC")
  .count

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
    @selected_currency = params[:currency]&.upcase || "KGS"

    # Convert all rates to the selected currency
    converted_rates = PsychologistProfile
                        .where.not(standard_rate: nil)
                        .map { |p| p.converted_rate(@selected_currency)&.to_f }
                        .compact

    @min_price = converted_rates.min || 0
    @max_price = converted_rates.max || 0
  end 

  def about_for_psych
  end

  def about_for_clients
  end

  def contact
  end
end
