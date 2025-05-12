require "application_system_test_case"

class ClientTypesTest < ApplicationSystemTestCase
  setup do
    @client_type = client_types(:one)
  end

  test "visiting the index" do
    visit client_types_url
    assert_selector "h1", text: "Client types"
  end

  test "should create client type" do
    visit client_types_url
    click_on "New client type"

    fill_in "Description", with: @client_type.description
    fill_in "Name", with: @client_type.name
    click_on "Create Client type"

    assert_text "Client type was successfully created"
    click_on "Back"
  end

  test "should update Client type" do
    visit client_type_url(@client_type)
    click_on "Edit this client type", match: :first

    fill_in "Description", with: @client_type.description
    fill_in "Name", with: @client_type.name
    click_on "Update Client type"

    assert_text "Client type was successfully updated"
    click_on "Back"
  end

  test "should destroy Client type" do
    visit client_type_url(@client_type)
    click_on "Destroy this client type", match: :first

    assert_text "Client type was successfully destroyed"
  end
end
