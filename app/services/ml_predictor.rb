class MlPredictor
  URL = "http://localhost:8000/predict"

  def self.predict(text)
    return [] if text.blank?

    response = Faraday.post(URL, { text: text }.to_json, "Content-Type" => "application/json")
    body = JSON.parse(response.body)

    body.is_a?(Array) ? body : []
  rescue => e
    Rails.logger.error("ML API error: #{e.message}")
    []
  end
end
