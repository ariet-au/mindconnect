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

  MAX_LABELS = 2      # show only top 2
  MIN_SCORE = 0.35    # minimum confidence threshold

  def create
    text = params[:text]
    raw_results = MlPredictor.predict(text) # array of hashes: [{label:, score:, confidence:}, ...]

    if raw_results.any?
      # Sort strongest first (already sorted in ML API, but safe)
      sorted = raw_results.sort_by { |r| -r["score"] }

      # Take top N labels
      top_results = sorted.first(MAX_LABELS)

      # Translate labels and convert score to percent for display
      top_results.each do |r|
        r["name"] = LABEL_TRANSLATIONS[r["label"]] || r["label"]
        r["percent"] = (r["score"] * 100).round(1)
        # Use the confidence text as-is from API
        r["message"] = r["confidence"]
      end

      top_label = top_results.first["label"]
      top_score = top_results.first["score"]
    else
      top_results = []
      top_label = nil
      top_score = nil
      @error = "Prediction service returned no result"
    end

    # Save prediction to DB
    @prediction = Prediction.create!(
      prompt: text,
      response: top_results,  # store top results including confidence string
      top_label: top_label,
      top_score: top_score,
      model_version: "rubert_v2"
    )

    # Render turbo frame
    render turbo_stream: turbo_stream.update(
      "prediction_result",
      partial: "predictions/result",
      locals: {
        results: top_results,
        error: @error,
        text: text,
        prediction: @prediction
      }
    )
  end


  def embedding_search
  end


  def run_embedding_search
    query = params[:query]
    return redirect_to embedding_search_predictions_path if query.blank?

    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    query_embedding = EmbeddingService.generate_for_query(query)
    vector_string = "[#{query_embedding.join(',')}]"

    # Select best similarity per profile
    chunks_with_distance = PsychologistMatchChunk
      .select(
        "psychologist_profile_id, MIN(embedding <=> '#{vector_string}'::vector) AS min_distance"
      )
      .group(:psychologist_profile_id)

    # Join back to profiles
    @psychologists = PsychologistProfile
      .joins("INNER JOIN (#{chunks_with_distance.to_sql}) AS chunk_match ON chunk_match.psychologist_profile_id = psychologist_profiles.id")
      .select(
        "psychologist_profiles.*",
        "(1 - chunk_match.min_distance) AS similarity_score"
      )
      .order("similarity_score DESC")
      .limit(10)
      .to_a

    @execution_time = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time).round(3)
    @result_count   = @psychologists.size

    render :embedding_search
  end

  def feedback
    prediction = Prediction.find(params[:id])
    correct = params[:correct] == "true"

    prediction.update!(
      user_marked_correct: correct,
      user_correct_label: params[:correct_label],
      feedback_at: Time.current
    )

    if correct
      predicted_labels = prediction.response.map { |r| { label: r["label"], score: r["score"] } }
      ranked_psychologists = ProfileMatcher.match_for_labels(predicted_labels)

      render turbo_stream: turbo_stream.update(
        "psychologist_results",
        partial: "predictions/psychologists",
        locals: { psychologists: ranked_psychologists }
      )
    else
      head :ok
    end
  end

  def admin
    # Show latest 100 submissions by default
    @predictions = Prediction.order(created_at: :desc).limit(100)
  end


  
end
