require "test_helper"

class ClientTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client_type = client_types(:one)
  end

  test "should get index" do
    get client_types_url
    assert_response :success
  end

  test "should get new" do
    get new_client_type_url
    assert_response :success
  end

  test "should create client_type" do
    assert_difference("ClientType.count") do
      post client_types_url, params: { client_type: { description: @client_type.description, name: @client_type.name } }
    end

    assert_redirected_to client_type_url(ClientType.last)
  end

  test "should show client_type" do
    get client_type_url(@client_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_client_type_url(@client_type)
    assert_response :success
  end

  test "should update client_type" do
    patch client_type_url(@client_type), params: { client_type: { description: @client_type.description, name: @client_type.name } }
    assert_redirected_to client_type_url(@client_type)
  end

  test "should destroy client_type" do
    assert_difference("ClientType.count", -1) do
      delete client_type_url(@client_type)
    end

    assert_redirected_to client_types_url
  end
end
