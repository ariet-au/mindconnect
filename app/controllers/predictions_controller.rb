class PredictionsController < ApplicationController
LABEL_TRANSLATIONS = {
  "mood_low_energy" => "Апатия и подавленность",
  "anxiety_fear" => "Тревога и страхи",
  "stress_burnout" => "Стресс и выгорание",
  "emotional_regulation" => "Сложные эмоции и гнев",
  "coping_behavior" => "Трудности в поведении",
  "trauma_past_experiences" => "Травматичный опыт",
  "romantic_relationships" => "Проблемы в отношениях",
  "family_parenting" => "Семья и дети",
  "identity_selfworth_life_direction" => "Самооценка и поиск себя",
  "behavior_addictions" => "Зависимости и вредные привычки",
  "grief_loss" => "Горе и Утрата",
  "life_transitions_career" => "Карьера и перемены",
  "social_interpersonal" => "Трудности в общении и социуме",
  "romantic_solo" => "Одиночество или разрыв"
}


  def new
  end

  def create
    text = params[:text]
    @results = MlPredictor.predict(text) # array of hashes

    if @results.any?
      @results.sort_by! { |r| -r["score"] } # optional
      top = @results.first
      top_label = top["label"]
      top_score = top["score"]
    else
      top_label = nil
      top_score = nil
      @error = "Prediction service returned no result"
    end

    @prediction = Prediction.create!(
      prompt: text,
      response: @results,
      top_label: top_label,
      top_score: top_score,
      model_version: "rubert_v1"
    )

    # Render the turbo frame as before
    render turbo_stream: turbo_stream.update(
      "prediction_result",
      partial: "predictions/result",
      locals: {
        results: @results,
        error: @error,
        text: text,
        prediction: @prediction
      }
    )
  end



  def feedback
    prediction = Prediction.find(params[:id])

    prediction.update!(
      user_marked_correct: params[:correct] == "true",
      user_correct_label: params[:correct_label],
      feedback_at: Time.current
    )

    head :ok
  end

  def admin
    # Show latest 100 submissions by default
    @predictions = Prediction.order(created_at: :desc).limit(100)
  end
end
