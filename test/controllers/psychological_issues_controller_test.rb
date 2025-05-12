require "test_helper"

class PsychologicalIssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @psychological_issue = psychological_issues(:one)
  end

  test "should get index" do
    get psychological_issues_url
    assert_response :success
  end

  test "should get new" do
    get new_psychological_issue_url
    assert_response :success
  end

  test "should create psychological_issue" do
    assert_difference("PsychologicalIssue.count") do
      post psychological_issues_url, params: { psychological_issue: { category: @psychological_issue.category, description: @psychological_issue.description, name: @psychological_issue.name, severity_level: @psychological_issue.severity_level } }
    end

    assert_redirected_to psychological_issue_url(PsychologicalIssue.last)
  end

  test "should show psychological_issue" do
    get psychological_issue_url(@psychological_issue)
    assert_response :success
  end

  test "should get edit" do
    get edit_psychological_issue_url(@psychological_issue)
    assert_response :success
  end

  test "should update psychological_issue" do
    patch psychological_issue_url(@psychological_issue), params: { psychological_issue: { category: @psychological_issue.category, description: @psychological_issue.description, name: @psychological_issue.name, severity_level: @psychological_issue.severity_level } }
    assert_redirected_to psychological_issue_url(@psychological_issue)
  end

  test "should destroy psychological_issue" do
    assert_difference("PsychologicalIssue.count", -1) do
      delete psychological_issue_url(@psychological_issue)
    end

    assert_redirected_to psychological_issues_url
  end
end
