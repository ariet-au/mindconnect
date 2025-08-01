require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:one)
  end

  test "visiting the index" do
    visit articles_url
    assert_selector "h1", text: "Articles"
  end

  test "should create article" do
    visit articles_url
    click_on "New article"

    fill_in "Body", with: @article.body
    check "Is published" if @article.is_published
    fill_in "Moderated at", with: @article.moderated_at
    fill_in "Moderated by admin", with: @article.moderated_by_admin_id
    fill_in "Moderation reason", with: @article.moderation_reason
    fill_in "Psychologist profile", with: @article.psychologist_profile_id
    fill_in "Published at", with: @article.published_at
    fill_in "Slug", with: @article.slug
    fill_in "Status", with: @article.status
    fill_in "Title", with: @article.title
    click_on "Create Article"

    assert_text "Article was successfully created"
    click_on "Back"
  end

  test "should update Article" do
    visit article_url(@article)
    click_on "Edit this article", match: :first

    fill_in "Body", with: @article.body
    check "Is published" if @article.is_published
    fill_in "Moderated at", with: @article.moderated_at.to_s
    fill_in "Moderated by admin", with: @article.moderated_by_admin_id
    fill_in "Moderation reason", with: @article.moderation_reason
    fill_in "Psychologist profile", with: @article.psychologist_profile_id
    fill_in "Published at", with: @article.published_at.to_s
    fill_in "Slug", with: @article.slug
    fill_in "Status", with: @article.status
    fill_in "Title", with: @article.title
    click_on "Update Article"

    assert_text "Article was successfully updated"
    click_on "Back"
  end

  test "should destroy Article" do
    visit article_url(@article)
    click_on "Destroy this article", match: :first

    assert_text "Article was successfully destroyed"
  end
end
