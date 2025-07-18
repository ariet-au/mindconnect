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


    def format_timezone_offset(timezone_identifier)
        return "N/A" unless timezone_identifier.present?

        begin
        tz = TZInfo::Timezone.get(timezone_identifier)
        # Get the current period to account for Daylight Saving Time
        current_period = tz.current_period
        # Calculate the UTC offset in hours
        offset_hours = current_period.offset.utc_total_offset / 3600.0
        # Format as "GMT+X" or "GMT-X"
        "GMT#{offset_hours >= 0 ? '+' : ''}#{offset_hours.to_i}"
        rescue TZInfo::InvalidTimezoneIdentifier
            "Invalid Time Zone" # Or handle as per your error policy
        end
    end

     def youtube_embed_url(youtube_url)
        return nil if youtube_url.blank?

        uri = URI.parse(youtube_url)
        if uri.host&.include?("youtube.com")
        CGI.parse(uri.query)["v"]&.first
        elsif uri.host&.include?("youtu.be")
        uri.path[1..] # remove leading slash
        end
    rescue
        nil
    end

end

