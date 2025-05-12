require "application_system_test_case"

class PsychologicalIssuesTest < ApplicationSystemTestCase
  setup do
    @psychological_issue = psychological_issues(:one)
  end

  test "visiting the index" do
    visit psychological_issues_url
    assert_selector "h1", text: "Psychological issues"
  end

  test "should create psychological issue" do
    visit psychological_issues_url
    click_on "New psychological issue"

    fill_in "Category", with: @psychological_issue.category
    fill_in "Description", with: @psychological_issue.description
    fill_in "Name", with: @psychological_issue.name
    fill_in "Severity level", with: @psychological_issue.severity_level
    click_on "Create Psychological issue"

    assert_text "Psychological issue was successfully created"
    click_on "Back"
  end

  test "should update Psychological issue" do
    visit psychological_issue_url(@psychological_issue)
    click_on "Edit this psychological issue", match: :first

    fill_in "Category", with: @psychological_issue.category
    fill_in "Description", with: @psychological_issue.description
    fill_in "Name", with: @psychological_issue.name
    fill_in "Severity level", with: @psychological_issue.severity_level
    click_on "Update Psychological issue"

    assert_text "Psychological issue was successfully updated"
    click_on "Back"
  end

  test "should destroy Psychological issue" do
    visit psychological_issue_url(@psychological_issue)
    click_on "Destroy this psychological issue", match: :first

    assert_text "Psychological issue was successfully destroyed"
  end
end
