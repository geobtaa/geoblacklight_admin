require "test_helper"

class DocumentDownloadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @document = documents(:ag)
    @document_download = document_downloads(:one)

    get "/users/sign_in"
    sign_in_as users(:user_001)
    post user_session_url

    follow_redirect!
    assert_response :success
  end

  test "should get index" do
    get admin_document_downloads_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_document_document_download_url(@document)
    assert_response :success
  end

  test "should create document_download" do
    assert_difference("DocumentDownload.count") do
      post admin_document_downloads_url, params: {document_download: {friendlier_id: @document_download.friendlier_id, label: @document_download.label, position: @document_download.position, value: @document_download.value}}
    end

    assert_redirected_to admin_document_document_downloads_url(@document)
  end

  test "should show document_download" do
    get admin_document_download_url(@document_download)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_document_document_download_url(@document, @document_download)
    assert_response :success
  end

  test "should update document_download" do
    patch admin_document_document_download_url(@document, @document_download), params: {document_download: {friendlier_id: @document_download.friendlier_id, label: @document_download.label, position: @document_download.position, value: @document_download.value}}
    assert_redirected_to admin_document_document_downloads_url(@document)
  end

  test "should destroy document_download" do
    assert_difference("DocumentDownload.count", -1) do
      delete admin_document_download_url(@document_download)
    end

    assert_redirected_to admin_document_downloads_url
  end

  test "should get import" do
    get import_admin_document_downloads_url
    assert_response :success
  end

  test "should get destroy_all" do
    get destroy_all_admin_document_downloads_url
    assert_response :success
  end
end
