Rails.application.configure do
  config.content_security_policy do |policy|
    # Default
    policy.default_src :self, :https

    # Fonts / Images
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data

    # Objects
    policy.object_src :none

    # Scripts
    # - :unsafe_eval needed for Alpine/Turbo (optional)
    # - :unsafe_inline needed for Amplitude Session Replay
    # - Allow CDN
    policy.script_src  :self, :https, :unsafe_eval, :unsafe_inline, "https://cdn.amplitude.com"
    policy.script_src_elem :self, :https, :unsafe_inline, "https://cdn.amplitude.com"

    # Network requests
    policy.connect_src :self, :https, "https://api2.amplitude.com", "https://*.amplitude.com"

    # Styles
    policy.style_src  :self, :https, :unsafe_inline, "https://cdn.amplitude.com"
  end

  # Nonce generator (optional, for other inline scripts)
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src)
end
