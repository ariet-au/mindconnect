class PredictionsController < ApplicationController
  LABEL_TRANSLATIONS = {
    "addictions_substance_use" => "Зависимости и употребление веществ",
    "trauma_ptsd" => "Травма / ПТСР",
    "emotional_regulation_anger" => "Эмоциональная регуляция / гнев",
    "depression_mood" => "Депрессия / Настроение",
    "anxiety_panic" => "Тревога / Паника",
    "child_adolescent_issues" => "Проблемы детей и подростков",
    "stress_burnout_life_transitions" => "Стресс, выгорание, жизненные изменения",
    "grief_loss" => "Горе и утрата",
    "family_conflict" => "Семейные конфликты"
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
