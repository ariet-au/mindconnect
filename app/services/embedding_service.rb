require "open3"
require "json"

class EmbeddingService
  VENV_PYTHON = Rails.root.join("../mindconnect-ml/venv/bin/python3")
  SCRIPT_PATH = Rails.root.join("script/embed_profile.py") # same name

  # Generates embedding for a PsychologistMatchChunk
  def self.generate_for_chunk(chunk)
    payload = { content: chunk.content }

    run_python(payload)
  end

  private

  def self.run_python(payload)
    # Open3 still needed if using system call to Python
    stdout, stderr, status = Open3.capture3(
      "#{VENV_PYTHON} #{SCRIPT_PATH}",
      stdin_data: payload.to_json
    )

    raise "Python embedding error: #{stderr}" unless status.success?

    JSON.parse(stdout)
  end
end