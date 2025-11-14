class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET /articles or /articles.json
  def index
    @articles = Article.published.order(created_at: :desc)

    # Grab all page views that contain '/articles/' in the URL
    page_views = PageView.where("url LIKE ?", "%/articles/%")

    # Build a hash: article_id => views_count
    @views_counts = page_views.each_with_object(Hash.new(0)) do |pv, hash|
      if pv.url =~ %r{/articles/(\d+)}
        article_id = $1.to_i
        hash[article_id] += 1
      end
    end
  end



  # GET /articles/1 or /articles/1.json
  def show
    @article = Article.find(params[:id])

    # Only create a page view if this session hasn't viewed this article yet
    unless PageView.exists?(session_id: session.id.to_s, url: request.fullpath)
      PageView.create!(
        user_id: current_user&.id,
        session_id: session.id.to_s,
        url: request.fullpath
      )
    end

    # Count views for this article by URL
    # Cache for 10 minutes to avoid counting every request
    @views_count = Rails.cache.fetch(["article-views", @article.id], expires_in: 10.minutes) do
      PageView.where("url LIKE ?", "%/articles/#{@article.id}").count
    end
  end


  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    @article = Article.new(article_params)
    @article.psychologist_profile_id ||= current_user.psychologist_profile.id if current_user.psychologist?
    @article.published_at = Time.current if @article.is_published && @article.published_at.blank?
    
    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update

    @article.published_at = Time.current if @article.is_published && @article.published_at.blank?

    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "Article was successfully updated." }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, status: :see_other, notice: "Article was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.expect(article: [ :psychologist_profile_id, :title, :body, :is_published, :published_at, :slug, :status, :moderated_by_admin_id, :moderation_reason, :moderated_at ])
    end
end
