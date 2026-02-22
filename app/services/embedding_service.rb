require "open3"
require "json"

class EmbeddingService
  # Python binary lives in the mindconnect-ml venv
  VENV_PYTHON = Rails.root.join("../mindconnect-ml/venv/bin/python3")
  
  # Python script is in the Rails project
  SCRIPT_PATH = Rails.root.join("script/embed_profile.py")

  def self.generate_for_profile(profile)
    payload = {
      about_me: profile.about_me,
      about_specialties: profile.about_specialties,
      about_issues: profile.about_issues,
      about_clients: profile.about_clients,
      specialties: profile.specialties.pluck(:name),
      client_types: profile.client_types.pluck(:name),
      issues: profile.issues.pluck(:name)
    }

    # Run Python script with payload
    stdout, stderr, status = Open3.capture3(
      "#{VENV_PYTHON} #{SCRIPT_PATH}",
      stdin_data: payload.to_json
    )

    raise "Python embedding error: #{stderr}" unless status.success?

    JSON.parse(stdout)
  end
end