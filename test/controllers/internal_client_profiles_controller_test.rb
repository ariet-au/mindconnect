require "test_helper"

class InternalClientProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @internal_client_profile = internal_client_profiles(:one)
  end

  test "should get index" do
    get internal_client_profiles_url
    assert_response :success
  end

  test "should get new" do
    get new_internal_client_profile_url
    assert_response :success
  end

  test "should create internal_client_profile" do
    assert_difference("InternalClientProfile.count") do
      post internal_client_profiles_url, params: { internal_client_profile: { address: @internal_client_profile.address, city: @internal_client_profile.city, client_profile_id: @internal_client_profile.client_profile_id, country: @internal_client_profile.country, dob: @internal_client_profile.dob, emergency_contact_name: @internal_client_profile.emergency_contact_name, emergency_contact_phone: @internal_client_profile.emergency_contact_phone, emergency_contact_relationship: @internal_client_profile.emergency_contact_relationship, first_name: @internal_client_profile.first_name, first_time_therapy: @internal_client_profile.first_time_therapy, gender: @internal_client_profile.gender, gp_contact_info: @internal_client_profile.gp_contact_info, gp_name: @internal_client_profile.gp_name, initial_assessment_summary: @internal_client_profile.initial_assessment_summary, internal_reference_number: @internal_client_profile.internal_reference_number, last_name: @internal_client_profile.last_name, phone_number1: @internal_client_profile.phone_number1, phone_number2: @internal_client_profile.phone_number2, preferred_contact_method: @internal_client_profile.preferred_contact_method, psychologist_profile_id: @internal_client_profile.psychologist_profile_id, reason_for_referral: @internal_client_profile.reason_for_referral, risk_assessment_summary: @internal_client_profile.risk_assessment_summary, status: @internal_client_profile.status, telegram: @internal_client_profile.telegram, treatment_plan_summary: @internal_client_profile.treatment_plan_summary, whatsapp: @internal_client_profile.whatsapp } }
    end

    assert_redirected_to internal_client_profile_url(InternalClientProfile.last)
  end

  test "should show internal_client_profile" do
    get internal_client_profile_url(@internal_client_profile)
    assert_response :success
  end

  test "should get edit" do
    get edit_internal_client_profile_url(@internal_client_profile)
    assert_response :success
  end

  test "should update internal_client_profile" do
    patch internal_client_profile_url(@internal_client_profile), params: { internal_client_profile: { address: @internal_client_profile.address, city: @internal_client_profile.city, client_profile_id: @internal_client_profile.client_profile_id, country: @internal_client_profile.country, dob: @internal_client_profile.dob, emergency_contact_name: @internal_client_profile.emergency_contact_name, emergency_contact_phone: @internal_client_profile.emergency_contact_phone, emergency_contact_relationship: @internal_client_profile.emergency_contact_relationship, first_name: @internal_client_profile.first_name, first_time_therapy: @internal_client_profile.first_time_therapy, gender: @internal_client_profile.gender, gp_contact_info: @internal_client_profile.gp_contact_info, gp_name: @internal_client_profile.gp_name, initial_assessment_summary: @internal_client_profile.initial_assessment_summary, internal_reference_number: @internal_client_profile.internal_reference_number, last_name: @internal_client_profile.last_name, phone_number1: @internal_client_profile.phone_number1, phone_number2: @internal_client_profile.phone_number2, preferred_contact_method: @internal_client_profile.preferred_contact_method, psychologist_profile_id: @internal_client_profile.psychologist_profile_id, reason_for_referral: @internal_client_profile.reason_for_referral, risk_assessment_summary: @internal_client_profile.risk_assessment_summary, status: @internal_client_profile.status, telegram: @internal_client_profile.telegram, treatment_plan_summary: @internal_client_profile.treatment_plan_summary, whatsapp: @internal_client_profile.whatsapp } }
    assert_redirected_to internal_client_profile_url(@internal_client_profile)
  end

  test "should destroy internal_client_profile" do
    assert_difference("InternalClientProfile.count", -1) do
      delete internal_client_profile_url(@internal_client_profile)
    end

    assert_redirected_to internal_client_profiles_url
  end
end
