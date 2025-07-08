require "test_helper"

class ClientProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client_profile = client_profiles(:one)
  end

  test "should get index" do
    get client_profiles_url
    assert_response :success
  end

  test "should get new" do
    get new_client_profile_url
    assert_response :success
  end

  test "should create client_profile" do
    assert_difference("ClientProfile.count") do
      post client_profiles_url, params: { client_profile: { address: @client_profile.address, city: @client_profile.city, country: @client_profile.country, dob: @client_profile.dob, gender: @client_profile.gender, name: @client_profile.name, phone_number1: @client_profile.phone_number1, phone_number2: @client_profile.phone_number2, telegram: @client_profile.telegram, timezone: @client_profile.timezone, user_id: @client_profile.user_id, whatsapp: @client_profile.whatsapp } }
    end

    assert_redirected_to client_profile_url(ClientProfile.last)
  end

  test "should show client_profile" do
    get client_profile_url(@client_profile)
    assert_response :success
  end

  test "should get edit" do
    get edit_client_profile_url(@client_profile)
    assert_response :success
  end

  test "should update client_profile" do
    patch client_profile_url(@client_profile), params: { client_profile: { address: @client_profile.address, city: @client_profile.city, country: @client_profile.country, dob: @client_profile.dob, gender: @client_profile.gender, name: @client_profile.name, phone_number1: @client_profile.phone_number1, phone_number2: @client_profile.phone_number2, telegram: @client_profile.telegram, timezone: @client_profile.timezone, user_id: @client_profile.user_id, whatsapp: @client_profile.whatsapp } }
    assert_redirected_to client_profile_url(@client_profile)
  end

  test "should destroy client_profile" do
    assert_difference("ClientProfile.count", -1) do
      delete client_profile_url(@client_profile)
    end

    assert_redirected_to client_profiles_url
  end
end
