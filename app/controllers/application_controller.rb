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
  helper_method :current_visitor_id
  helper_method :hero_test_group
  helper_method :browser_timezone_from_session





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

    def browser_timezone_from_session
      session[:browser_timezone] || cookies[:browser_timezone]
    end
  
    
  # experiement shit
  def hero_test_group
    # This turns the visitor_id into a stable "A" or "B"
    # No randomness, no session storage.
    Zlib.crc32(current_visitor_id) % 2 == 0 ? "A" : "B"
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
  # 1. NEW: Generate or retrieve the visitor_id
  def current_visitor_id
    if cookies[:analytics_consent] == 'true'
      # Path A: Consent given. Use a permanent signed cookie.
      # This allows tracking the same person for years.
      cookies.permanent.signed[:visitor_id] ||= SecureRandom.uuid
    else
      # Path B: No consent. Generate an ID that only lasts for today.
      # It uses IP + UA so it's stable for this visit but expires tomorrow.
      generate_ephemeral_id
    end
  end

  def generate_ephemeral_id
    salt = Rails.application.credentials.secret_key_base || "temporary_salt"
    # Create a 13-character hash unique to this IP/UA/Date combination
    Digest::SHA256.hexdigest("#{request.remote_ip}-#{request.user_agent}-#{Date.today}-#{salt}")[0..12]
  end
  
  def track_page_view
    return if request.path.starts_with?("/assets") || request.xhr?

    # Ensure we only track if it's a real person or we are okay with anonymous stats
    PageView.create!(
      visitor_id: current_visitor_id, 
      user: current_user,
      session_id: session.id.to_s,
      url: request.fullpath,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      viewed_at: Time.current
    )
  rescue => e
    # Check your terminal/logs right now! If this fails, the error will pop up here.
    Rails.logger.error("PageView tracking failed: #{e.message}")
  end

  def track_user_session
    return unless session.id.present?

    session_id_str = session.id.to_s  # <-- convert to string

    @user_session ||= UserSession.find_or_create_by(session_id: session_id_str) do |s|
      s.visitor_id = current_visitor_id # <--- Added this
      s.user = current_user
      s.started_at = Time.current
      s.device_type = request.user_agent&.match(/Mobile|Android|iPhone/) ? "mobile" : "desktop"
    end

    # Optionally update last seen time
    @user_session.update!(ended_at: Time.current)
  end
  
end
