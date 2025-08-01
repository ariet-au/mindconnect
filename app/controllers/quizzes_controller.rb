class QuizzesController < ApplicationController
before_action :authenticate_user!, except: [:index, :show]
before_action :set_quiz, only: [:show, :edit, :update, :destroy]

  # GET /quizzes or /quizzes.json
  def index
    @quizzes = Quiz.all
  end

  # GET /quizzes/1 or /quizzes/1.json
  def show
  end

  # GET /quizzes/new
  def new
    @quiz = current_user.quizzes.build
    3.times do
      question = @quiz.questions.build(input_type: "likert")
      4.times { |i| question.question_options.build(label: "Option #{i + 1}", score: i) }
    end
  end

  # GET /quizzes/1/edit
  def edit
    redirect_to quizzes_path, alert: "Not authorized" unless @quiz.user == current_user
  end

  # POST /quizzes or /quizzes.json
  def create
    @quiz = Quiz.new(quiz_params)
    @quiz.user = current_user

    respond_to do |format|
      if @quiz.save
        format.html { redirect_to @quiz, notice: "Quiz was successfully created." }
        format.json { render :show, status: :created, location: @quiz }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quizzes/1 or /quizzes/1.json
  def update
    return redirect_to quizzes_path, alert: "Not authorized" unless @quiz.user == current_user

    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html { redirect_to @quiz, notice: "Quiz was successfully updated." }
        format.json { render :show, status: :ok, location: @quiz }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1 or /quizzes/1.json
  def destroy
    @quiz.destroy!

    respond_to do |format|
      format.html { redirect_to quizzes_path, status: :see_other, notice: "Quiz was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  def take
      @quiz = Quiz.includes(questions: :question_options).find(params[:id])
  end

  # def submit
  #   @quiz = Quiz.includes(questions: :question_options).find(params[:id])
  #   responses = params[:responses] || {}

  #   @missing_questions = []
  #   total_score = 0

  #   @quiz.questions.each do |question|
  #     response = responses[question.id.to_s]
  #     if response.nil?
  #       @missing_questions << question
  #     else
  #       total_score += response.to_i
  #     end
  #   end

  #   if @missing_questions.any?
  #     flash.now[:alert] = "Please answer all questions before submitting."
  #     render :take, status: :unprocessable_entity and return
  #   end

  #   result = case total_score
  #     when 0..4 then "Minimal or no depression"
  #     when 5..9 then "Mild depression"
  #     when 10..14 then "Moderate depression"
  #     when 15..19 then "Moderately severe depression"
  #     else "Severe depression"
  #   end

  #   # Store in session and redirect
  #   session[:quiz_result] = { score: total_score, result: result }
  #   redirect_to result_quiz_path(@quiz)
  # end
  def submit
  @quiz = Quiz.includes(questions: :question_options).find(params[:id])
  responses = params[:responses] || {}

  @missing_questions = []
  total_score = 0

  @quiz.questions.each do |question|
    response = responses[question.id.to_s]
    if response.nil?
      @missing_questions << question
    else
      total_score += response.to_i
    end
  end

  if @missing_questions.any?
    flash.now[:alert] = "Please answer all questions before submitting."
    render :take, status: :unprocessable_entity and return
  end

  interpretation = case total_score
    when 0..4 then "Minimal or no depression"
    when 5..9 then "Mild depression"
    when 10..14 then "Moderate depression"
    when 15..19 then "Moderately severe depression"
    else "Severe depression"
  end

  # Pass results in the redirect URL
  redirect_to result_quiz_path(@quiz, score: total_score, result: interpretation)
end



  # def result
  #   @quiz = Quiz.find(params[:id])
  #   result_data = session[:quiz_result] # no delete

  #   if result_data.nil?
  #     redirect_to take_quiz_path(@quiz), alert: "Please complete the quiz first."
  #     return
  #   end

  #   @total_score = result_data[:score]
  #   @result = result_data[:result]
  # end
def result
  @quiz = Quiz.find(params[:id])
  @total_score = params[:score]
  @result = params[:result]

  if @total_score.blank? || @result.blank?
    redirect_to take_quiz_path(@quiz), alert: "Please complete the quiz first."
  end
end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quiz
      @quiz = Quiz.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def quiz_params
        params.require(:quiz).permit(:title, :description,
          questions_attributes: [
            :text, :input_type,
            question_options_attributes: [:label, :score]
          ])    
    end
end
