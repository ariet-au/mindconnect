module ApplicationHelper
     def any_filters_active?(params)
            params[:search].present? ||
            params[:specialty_ids].present? ||
            params[:issue_ids].present? ||
            params[:client_type_ids].present? ||
            params[:country].present? ||
            params[:city].present?
    end


    def countries_with_cities
        YAML.load_file(Rails.root.join('config', 'countries_cities.yml'))
    end


end

