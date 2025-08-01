require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
  end

  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get new" do
    get new_article_url
    assert_response :success
  end

  test "should create article" do
    assert_difference("Article.count") do
      post articles_url, params: { article: { body: @article.body, is_published: @article.is_published, moderated_at: @article.moderated_at, moderated_by_admin_id: @article.moderated_by_admin_id, moderation_reason: @article.moderation_reason, psychologist_profile_id: @article.psychologist_profile_id, published_at: @article.published_at, slug: @article.slug, status: @article.status, title: @article.title } }
    end

    assert_redirected_to article_url(Article.last)
  end

  test "should show article" do
    get article_url(@article)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "should update article" do
    patch article_url(@article), params: { article: { body: @article.body, is_published: @article.is_published, moderated_at: @article.moderated_at, moderated_by_admin_id: @article.moderated_by_admin_id, moderation_reason: @article.moderation_reason, psychologist_profile_id: @article.psychologist_profile_id, published_at: @article.published_at, slug: @article.slug, status: @article.status, title: @article.title } }
    assert_redirected_to article_url(@article)
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end
end
