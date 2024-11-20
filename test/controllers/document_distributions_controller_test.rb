require "test_helper"

class DocumentReferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @document = documents(:ls)
    @document_distribution = document_distributions(:one)
    @file = fixture_file_upload("import_distributions.csv", "text/csv")

    get "/users/sign_in"
    sign_in_as users(:user_001)
    post user_session_url

    follow_redirect!
    assert_response :success
  end

  test "should get index" do
    get admin_document_document_distributions_url(@document)
    assert_response :success
  end

  test "should get new" do
    get new_admin_document_document_distribution_url(@document)
    assert_response :success
  end

  test "should create document_distribution" do
    assert_difference("DocumentDistribution.count") do
      post admin_document_document_distributions_url(@document), params: {document_distribution: {
        friendlier_id: "35c8a641589c4e13b7aa11e37f3f00a1_0",
        reference_type_id: ReferenceType.first.id,
        url: "https://example.com"
      }}
    end

    assert_redirected_to admin_document_document_distributions_url(@document)
  end

  test "should show document_distribution" do
    get admin_document_document_distribution_url(@document, @document_distribution)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_document_document_distribution_url(@document, @document_distribution)
    assert_response :success
  end

  test "should update document_distribution" do
    patch admin_document_document_distribution_url(@document, @document_distribution), params: {
      document_distribution: {
        friendlier_id: "35c8a641589c4e13b7aa11e37f3f00a1_0",
        reference_type_id: ReferenceType.first.id,
        url: "https://example2.com"
      }
    }
    assert_redirected_to admin_document_document_distributions_url(@document)
  end

  test "should destroy document_distribution" do
    assert_difference("DocumentDistribution.count", -1) do
      delete admin_document_document_distribution_url(@document, @document_distribution)
    end

    assert_redirected_to admin_document_document_distributions_url(@document)
  end

  test "should import distributions successfully" do
    post import_admin_document_distributions_url(@document), params: {document_id: @document.friendlier_id, document_distribution: {distributions: {file: @file}}}
    assert_redirected_to admin_document_document_distributions_path(@document)
    assert_equal "Distributions were created successfully.", flash[:notice]
  end

  test "should not import distributions with invalid file" do
    post import_admin_document_distributions_url(@document), params: {document_id: @document.friendlier_id, document_distribution: {distributions: {file: nil}}}
    assert_redirected_to admin_document_document_distributions_path(@document)
    assert_equal "Distributions could not be created. File does not exist or is invalid.", flash[:notice]
  end
end
