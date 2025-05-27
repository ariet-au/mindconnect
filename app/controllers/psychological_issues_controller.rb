class PsychologicalIssuesController < ApplicationController
  before_action :set_psychological_issue, only: %i[ show edit update destroy ]
  # GET /psychological_issues or /psychological_issues.json
  def index
    @psychological_issues = PsychologicalIssue.all
  end

  # GET /psychological_issues/1 or /psychological_issues/1.json
  def show
  end

  # GET /psychological_issues/new
  def new
    @psychological_issue = PsychologicalIssue.new
  end

  # GET /psychological_issues/1/edit
  def edit
  end

  # POST /psychological_issues or /psychological_issues.json
  def create
    @psychological_issue = PsychologicalIssue.new(psychological_issue_params)

    respond_to do |format|
      if @psychological_issue.save
        format.html { redirect_to @psychological_issue, notice: "Psychological issue was successfully created." }
        format.json { render :show, status: :created, location: @psychological_issue }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @psychological_issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /psychological_issues/1 or /psychological_issues/1.json
  def update
    respond_to do |format|
      if @psychological_issue.update(psychological_issue_params)
        format.html { redirect_to @psychological_issue, notice: "Psychological issue was successfully updated." }
        format.json { render :show, status: :ok, location: @psychological_issue }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @psychological_issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /psychological_issues/1 or /psychological_issues/1.json
  def destroy
    @psychological_issue.destroy!

    respond_to do |format|
      format.html { redirect_to psychological_issues_path, status: :see_other, notice: "Psychological issue was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_psychological_issue
      @psychological_issue = PsychologicalIssue.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def psychological_issue_params
      params.expect(psychological_issue: [ :name, :description, :category, :severity_level ])
    end

 
end
