require "application_system_test_case"

class InternalClientProfilesTest < ApplicationSystemTestCase
  setup do
    @internal_client_profile = internal_client_profiles(:one)
  end

  test "visiting the index" do
    visit internal_client_profiles_url
    assert_selector "h1", text: "Internal client profiles"
  end

  test "should create internal client profile" do
    visit internal_client_profiles_url
    click_on "New internal client profile"

    fill_in "Address", with: @internal_client_profile.address
    fill_in "City", with: @internal_client_profile.city
    fill_in "Client profile", with: @internal_client_profile.client_profile_id
    fill_in "Country", with: @internal_client_profile.country
    fill_in "Dob", with: @internal_client_profile.dob
    fill_in "Emergency contact name", with: @internal_client_profile.emergency_contact_name
    fill_in "Emergency contact phone", with: @internal_client_profile.emergency_contact_phone
    fill_in "Emergency contact relationship", with: @internal_client_profile.emergency_contact_relationship
    fill_in "First name", with: @internal_client_profile.first_name
    check "First time therapy" if @internal_client_profile.first_time_therapy
    fill_in "Gender", with: @internal_client_profile.gender
    fill_in "Gp contact info", with: @internal_client_profile.gp_contact_info
    fill_in "Gp name", with: @internal_client_profile.gp_name
    fill_in "Initial assessment summary", with: @internal_client_profile.initial_assessment_summary
    fill_in "Internal reference number", with: @internal_client_profile.internal_reference_number
    fill_in "Last name", with: @internal_client_profile.last_name
    fill_in "Phone number1", with: @internal_client_profile.phone_number1
    fill_in "Phone number2", with: @internal_client_profile.phone_number2
    fill_in "Preferred contact method", with: @internal_client_profile.preferred_contact_method
    fill_in "Psychologist profile", with: @internal_client_profile.psychologist_profile_id
    fill_in "Reason for referral", with: @internal_client_profile.reason_for_referral
    fill_in "Risk assessment summary", with: @internal_client_profile.risk_assessment_summary
    fill_in "Status", with: @internal_client_profile.status
    fill_in "Telegram", with: @internal_client_profile.telegram
    fill_in "Treatment plan summary", with: @internal_client_profile.treatment_plan_summary
    fill_in "Whatsapp", with: @internal_client_profile.whatsapp
    click_on "Create Internal client profile"

    assert_text "Internal client profile was successfully created"
    click_on "Back"
  end

  test "should update Internal client profile" do
    visit internal_client_profile_url(@internal_client_profile)
    click_on "Edit this internal client profile", match: :first

    fill_in "Address", with: @internal_client_profile.address
    fill_in "City", with: @internal_client_profile.city
    fill_in "Client profile", with: @internal_client_profile.client_profile_id
    fill_in "Country", with: @internal_client_profile.country
    fill_in "Dob", with: @internal_client_profile.dob
    fill_in "Emergency contact name", with: @internal_client_profile.emergency_contact_name
    fill_in "Emergency contact phone", with: @internal_client_profile.emergency_contact_phone
    fill_in "Emergency contact relationship", with: @internal_client_profile.emergency_contact_relationship
    fill_in "First name", with: @internal_client_profile.first_name
    check "First time therapy" if @internal_client_profile.first_time_therapy
    fill_in "Gender", with: @internal_client_profile.gender
    fill_in "Gp contact info", with: @internal_client_profile.gp_contact_info
    fill_in "Gp name", with: @internal_client_profile.gp_name
    fill_in "Initial assessment summary", with: @internal_client_profile.initial_assessment_summary
    fill_in "Internal reference number", with: @internal_client_profile.internal_reference_number
    fill_in "Last name", with: @internal_client_profile.last_name
    fill_in "Phone number1", with: @internal_client_profile.phone_number1
    fill_in "Phone number2", with: @internal_client_profile.phone_number2
    fill_in "Preferred contact method", with: @internal_client_profile.preferred_contact_method
    fill_in "Psychologist profile", with: @internal_client_profile.psychologist_profile_id
    fill_in "Reason for referral", with: @internal_client_profile.reason_for_referral
    fill_in "Risk assessment summary", with: @internal_client_profile.risk_assessment_summary
    fill_in "Status", with: @internal_client_profile.status
    fill_in "Telegram", with: @internal_client_profile.telegram
    fill_in "Treatment plan summary", with: @internal_client_profile.treatment_plan_summary
    fill_in "Whatsapp", with: @internal_client_profile.whatsapp
    click_on "Update Internal client profile"

    assert_text "Internal client profile was successfully updated"
    click_on "Back"
  end

  test "should destroy Internal client profile" do
    visit internal_client_profile_url(@internal_client_profile)
    click_on "Destroy this internal client profile", match: :first

    assert_text "Internal client profile was successfully destroyed"
  end
end
