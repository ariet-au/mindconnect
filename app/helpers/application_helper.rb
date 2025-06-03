module ApplicationHelper
     def any_filters_active?(params)
        params[:search].present? ||
        params[:specialty_ids].present? ||
        params[:issue_ids].present? ||
        params[:client_type_ids].present? ||
        params[:language_ids].present? ||
        params[:in_person] == "1" ||
        params[:online] == "1" ||
        params[:country].present? ||
        params[:city].present? ||
        params[:gender].present? ||
        params[:min_rate].present? ||
        params[:max_rate].present?
    end


    def countries_with_cities
        YAML.load_file(Rails.root.join('config', 'countries_cities.yml'))
    end


end

