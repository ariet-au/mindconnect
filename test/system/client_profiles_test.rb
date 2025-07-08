require "application_system_test_case"

class ClientProfilesTest < ApplicationSystemTestCase
  setup do
    @client_profile = client_profiles(:one)
  end

  test "visiting the index" do
    visit client_profiles_url
    assert_selector "h1", text: "Client profiles"
  end

  test "should create client profile" do
    visit client_profiles_url
    click_on "New client profile"

    fill_in "Address", with: @client_profile.address
    fill_in "City", with: @client_profile.city
    fill_in "Country", with: @client_profile.country
    fill_in "Dob", with: @client_profile.dob
    fill_in "Gender", with: @client_profile.gender
    fill_in "Name", with: @client_profile.name
    fill_in "Phone number1", with: @client_profile.phone_number1
    fill_in "Phone number2", with: @client_profile.phone_number2
    fill_in "Telegram", with: @client_profile.telegram
    fill_in "Timezone", with: @client_profile.timezone
    fill_in "User", with: @client_profile.user_id
    fill_in "Whatsapp", with: @client_profile.whatsapp
    click_on "Create Client profile"

    assert_text "Client profile was successfully created"
    click_on "Back"
  end

  test "should update Client profile" do
    visit client_profile_url(@client_profile)
    click_on "Edit this client profile", match: :first

    fill_in "Address", with: @client_profile.address
    fill_in "City", with: @client_profile.city
    fill_in "Country", with: @client_profile.country
    fill_in "Dob", with: @client_profile.dob
    fill_in "Gender", with: @client_profile.gender
    fill_in "Name", with: @client_profile.name
    fill_in "Phone number1", with: @client_profile.phone_number1
    fill_in "Phone number2", with: @client_profile.phone_number2
    fill_in "Telegram", with: @client_profile.telegram
    fill_in "Timezone", with: @client_profile.timezone
    fill_in "User", with: @client_profile.user_id
    fill_in "Whatsapp", with: @client_profile.whatsapp
    click_on "Update Client profile"

    assert_text "Client profile was successfully updated"
    click_on "Back"
  end

  test "should destroy Client profile" do
    visit client_profile_url(@client_profile)
    click_on "Destroy this client profile", match: :first

    assert_text "Client profile was successfully destroyed"
  end
end
