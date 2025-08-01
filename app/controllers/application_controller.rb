class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_analytics_consent


  helper_method :current_currency
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] ||
                  session[:locale] ||
                  extract_locale_from_accept_language_header ||
                  I18n.default_locale
  end

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

  def check_analytics_consent
    # Only send analytics server-side if consent given
    @analytics_allowed = cookies[:analytics_consent] == 'true'
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first&.to_sym
  end
    # Ensure timezone is permitted in params
    def set_timezone_params
      params.require(:timezone)
    end
  
end
