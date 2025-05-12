require "application_system_test_case"

class PsychologistProfilesTest < ApplicationSystemTestCase
  setup do
    @psychologist_profile = psychologist_profiles(:one)
  end

  test "visiting the index" do
    visit psychologist_profiles_url
    assert_selector "h1", text: "Psychologist profiles"
  end

  test "should create psychologist profile" do
    visit psychologist_profiles_url
    click_on "New psychologist profile"

    fill_in "Address", with: @psychologist_profile.address
    fill_in "Bio", with: @psychologist_profile.bio
    fill_in "City", with: @psychologist_profile.city
    fill_in "Contact phone", with: @psychologist_profile.contact_phone
    fill_in "Contact phone2", with: @psychologist_profile.contact_phone2
    fill_in "Contact phone3", with: @psychologist_profile.contact_phone3
    fill_in "Country", with: @psychologist_profile.country
    fill_in "Education", with: @psychologist_profile.education
    fill_in "Gender", with: @psychologist_profile.gender
    fill_in "Is degree boolean", with: @psychologist_profile.is_degree_boolean
    check "Is doctor" if @psychologist_profile.is_doctor
    fill_in "License number", with: @psychologist_profile.license_number
    fill_in "Specialties", with: @psychologist_profile.specialties
    fill_in "Telegram", with: @psychologist_profile.telegram
    fill_in "Title", with: @psychologist_profile.title
    fill_in "User", with: @psychologist_profile.user_id
    fill_in "Whatsapp", with: @psychologist_profile.whatsapp
    fill_in "Years of experience", with: @psychologist_profile.years_of_experience
    click_on "Create Psychologist profile"

    assert_text "Psychologist profile was successfully created"
    click_on "Back"
  end

  test "should update Psychologist profile" do
    visit psychologist_profile_url(@psychologist_profile)
    click_on "Edit this psychologist profile", match: :first

    fill_in "Address", with: @psychologist_profile.address
    fill_in "Bio", with: @psychologist_profile.bio
    fill_in "City", with: @psychologist_profile.city
    fill_in "Contact phone", with: @psychologist_profile.contact_phone
    fill_in "Contact phone2", with: @psychologist_profile.contact_phone2
    fill_in "Contact phone3", with: @psychologist_profile.contact_phone3
    fill_in "Country", with: @psychologist_profile.country
    fill_in "Education", with: @psychologist_profile.education
    fill_in "Gender", with: @psychologist_profile.gender
    fill_in "Is degree boolean", with: @psychologist_profile.is_degree_boolean
    check "Is doctor" if @psychologist_profile.is_doctor
    fill_in "License number", with: @psychologist_profile.license_number
    fill_in "Specialties", with: @psychologist_profile.specialties
    fill_in "Telegram", with: @psychologist_profile.telegram
    fill_in "Title", with: @psychologist_profile.title
    fill_in "User", with: @psychologist_profile.user_id
    fill_in "Whatsapp", with: @psychologist_profile.whatsapp
    fill_in "Years of experience", with: @psychologist_profile.years_of_experience
    click_on "Update Psychologist profile"

    assert_text "Psychologist profile was successfully updated"
    click_on "Back"
  end

  test "should destroy Psychologist profile" do
    visit psychologist_profile_url(@psychologist_profile)
    click_on "Destroy this psychologist profile", match: :first

    assert_text "Psychologist profile was successfully destroyed"
  end
end
