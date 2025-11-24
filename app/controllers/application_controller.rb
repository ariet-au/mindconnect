class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_analytics_consent
  before_action do
    Thread.current[:viewer_timezone] = cookies[:viewer_timezone]
  end
  before_action :track_page_view
  before_action :track_user_session



  helper_method :current_currency
  before_action :set_locale

  




  def default_url_options
    { locale: I18n.locale }
  end



  def set_currency
    session[:currency] = params[:currency]
    redirect_back fallback_location: root_path
  end

  def current_currency
    session[:currency] || 'KGS'
  end

    def set_timezone
    # Store the timezone in the session or cookies for later use in the backend
      session[:browser_timezone] = params[:timezone]
      cookies[:browser_timezone] = { value: params[:timezone], expires: 1.year.from_now }

      head :ok # Send a 200 OK response with no content
    end

    # Add this helper to access the browser timezone from anywhere in your app
    helper_method :browser_timezone_from_session

    def browser_timezone_from_session
      session[:browser_timezone] || cookies[:browser_timezone]
    end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end

  private

  def after_sign_in_path_for(resource)
    if resource.psychologist?
      psychologist_profile_path(resource.psychologist_profile)
    else
      psychologist_profiles_path
    end
  end 

  def check_analytics_consent
    # Only send analytics server-side if consent given
    @analytics_allowed = cookies[:analytics_consent] == 'true'
  end

  # def extract_locale_from_accept_language_header
  #   request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first&.to_sym
  # end

  def set_viewer_timezone
    @viewer_timezone = cookies[:viewer_timezone] || 'UTC'
  end

  # Ensure timezone is permitted in params
  def set_timezone_params
    params.require(:timezone)
  end

  

  def set_locale
    I18n.locale =
      params[:locale] ||
      session[:locale] ||
      extract_locale_from_accept_language_header ||
      extract_locale_from_ip ||
      I18n.default_locale

    session[:locale] = I18n.locale
  end

  def extract_locale_from_accept_language_header
    lang = request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    lang&.to_sym if I18n.available_locales.map(&:to_s).include?(lang)
  end

  def extract_locale_from_ip
    location = Geocoder.search(request.remote_ip).first
    country_code = location&.country_code
    return nil unless country_code

    locale_map = {
      "RU" => :ru,
      "BY" => :ru,
      "KZ" => :ru,
      "FR" => :fr,
      "BE" => :fr,
      "CH" => :fr
    }

    locale_map[country_code]
  end

  def track_page_view
    # Skip logging for assets and AJAX calls if you want
    return if request.path.starts_with?("/assets") || request.xhr?

    PageView.create!(
      user: current_user,
      session_id: session.id,
      url: request.fullpath,
      referrer: request.referrer,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      viewed_at: Time.current
    )
  rescue => e
    Rails.logger.error("PageView tracking failed: #{e.message}")
  end

  def track_user_session
    return unless session.id.present?

    session_id_str = session.id.to_s  # <-- convert to string

    @user_session ||= UserSession.find_or_create_by(session_id: session_id_str) do |s|
      s.user = current_user
      s.started_at = Time.current
      s.device_type = request.user_agent&.match(/Mobile|Android|iPhone/) ? "mobile" : "desktop"
    end

    # Optionally update last seen time
    @user_session.update!(ended_at: Time.current)
  end
  
end
