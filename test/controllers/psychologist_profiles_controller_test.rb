require "test_helper"

class PsychologistProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @psychologist_profile = psychologist_profiles(:one)
  end

  test "should get index" do
    get psychologist_profiles_url
    assert_response :success
  end

  test "should get new" do
    get new_psychologist_profile_url
    assert_response :success
  end

  test "should create psychologist_profile" do
    assert_difference("PsychologistProfile.count") do
      post psychologist_profiles_url, params: { psychologist_profile: { address: @psychologist_profile.address, bio: @psychologist_profile.bio, city: @psychologist_profile.city, contact_phone: @psychologist_profile.contact_phone, contact_phone2: @psychologist_profile.contact_phone2, contact_phone3: @psychologist_profile.contact_phone3, country: @psychologist_profile.country, education: @psychologist_profile.education, gender: @psychologist_profile.gender, is_degree_boolean: @psychologist_profile.is_degree_boolean, is_doctor: @psychologist_profile.is_doctor, license_number: @psychologist_profile.license_number, specialties: @psychologist_profile.specialties, telegram: @psychologist_profile.telegram, title: @psychologist_profile.title, user_id: @psychologist_profile.user_id, whatsapp: @psychologist_profile.whatsapp, years_of_experience: @psychologist_profile.years_of_experience } }
    end

    assert_redirected_to psychologist_profile_url(PsychologistProfile.last)
  end

  test "should show psychologist_profile" do
    get psychologist_profile_url(@psychologist_profile)
    assert_response :success
  end

  test "should get edit" do
    get edit_psychologist_profile_url(@psychologist_profile)
    assert_response :success
  end

  test "should update psychologist_profile" do
    patch psychologist_profile_url(@psychologist_profile), params: { psychologist_profile: { address: @psychologist_profile.address, bio: @psychologist_profile.bio, city: @psychologist_profile.city, contact_phone: @psychologist_profile.contact_phone, contact_phone2: @psychologist_profile.contact_phone2, contact_phone3: @psychologist_profile.contact_phone3, country: @psychologist_profile.country, education: @psychologist_profile.education, gender: @psychologist_profile.gender, is_degree_boolean: @psychologist_profile.is_degree_boolean, is_doctor: @psychologist_profile.is_doctor, license_number: @psychologist_profile.license_number, specialties: @psychologist_profile.specialties, telegram: @psychologist_profile.telegram, title: @psychologist_profile.title, user_id: @psychologist_profile.user_id, whatsapp: @psychologist_profile.whatsapp, years_of_experience: @psychologist_profile.years_of_experience } }
    assert_redirected_to psychologist_profile_url(@psychologist_profile)
  end

  test "should destroy psychologist_profile" do
    assert_difference("PsychologistProfile.count", -1) do
      delete psychologist_profile_url(@psychologist_profile)
    end

    assert_redirected_to psychologist_profiles_url
  end
end
