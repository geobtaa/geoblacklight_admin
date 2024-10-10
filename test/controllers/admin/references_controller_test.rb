require "test_helper"

class Admin::ReferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reference = Reference.first

    get "/users/sign_in"
    sign_in_as users(:user_001)
    post user_session_url

    follow_redirect!
    assert_response :success
  end

  test "should get index" do
    get admin_references_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_reference_url
    assert_response :success
  end

  test "should create reference" do
    assert_difference("Reference.count") do
      post admin_references_url, params: {reference: {name: "New Reference"}}
    end

    assert_redirected_to reference_url(Reference.last)
  end

  test "should show reference" do
    get admin_reference_url(@reference)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_reference_url(@reference)
    assert_response :success
  end

  test "should update reference" do
    patch admin_reference_url(@reference), params: {reference: {name: "Updated Reference"}}
    assert_redirected_to reference_url(@reference)
  end

  test "should destroy reference" do
    assert_difference("Reference.count", -1) do
      delete admin_reference_url(@reference)
    end

    assert_redirected_to admin_references_url
  end

  test "should sort references" do
    post sort_admin_references_url, params: {id_list: [@reference.id]}
    assert_response :success
  end
end
