class PredictionsController < ApplicationController
  def new
    # Just render the form
  end

  def create
    text = params[:text]
    @results = MlPredictor.predict(text) # array of hashes

    if @results.any?
      @results.sort_by! { |r| -r["score"] } # optional: sort by confidence
    else
      @error = "Prediction service returned no result"
    end

    # Render only the Turbo Frame content, so multiple submissions just update the frame
    render turbo_stream: turbo_stream.update("prediction_result", partial: "predictions/result", locals: { results: @results, error: @error, text: text })
  end
end
