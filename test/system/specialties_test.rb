require "application_system_test_case"

class SpecialtiesTest < ApplicationSystemTestCase
  setup do
    @specialty = specialties(:one)
  end

  test "visiting the index" do
    visit specialties_url
    assert_selector "h1", text: "Specialties"
  end

  test "should create specialty" do
    visit specialties_url
    click_on "New specialty"

    fill_in "Description", with: @specialty.description
    fill_in "Name", with: @specialty.name
    click_on "Create Specialty"

    assert_text "Specialty was successfully created"
    click_on "Back"
  end

  test "should update Specialty" do
    visit specialty_url(@specialty)
    click_on "Edit this specialty", match: :first

    fill_in "Description", with: @specialty.description
    fill_in "Name", with: @specialty.name
    click_on "Update Specialty"

    assert_text "Specialty was successfully updated"
    click_on "Back"
  end

  test "should destroy Specialty" do
    visit specialty_url(@specialty)
    click_on "Destroy this specialty", match: :first

    assert_text "Specialty was successfully destroyed"
  end
end
