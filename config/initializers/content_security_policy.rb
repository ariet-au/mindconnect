Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src :self, :unsafe_inline, "https://cdn.amplitude.com"
  policy.script_src_elem :self, "https://cdn.amplitude.com"
  policy.style_src :self, :unsafe_inline, "https://cdn.amplitude.com"
  policy.style_src_elem :self, "https://cdn.amplitude.com"
  policy.connect_src :self, "https://api2.amplitude.com"
end