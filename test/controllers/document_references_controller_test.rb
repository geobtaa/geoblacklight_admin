require "test_helper"

class DocumentReferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @document = documents(:ls)
    @document_reference = document_references(:one)
    @file = fixture_file_upload("import_references.csv", "text/csv")

    get "/users/sign_in"
    sign_in_as users(:user_001)
    post user_session_url

    follow_redirect!
    assert_response :success
  end

  test "should get index" do
    get admin_document_document_references_url(@document)
    assert_response :success
  end

  test "should get new" do
    get new_admin_document_document_reference_url(@document)
    assert_response :success
  end

  test "should create document_reference" do
    assert_difference("DocumentReference.count") do
      post admin_document_document_references_url(@document), params: {document_reference: {
        friendlier_id: "35c8a641589c4e13b7aa11e37f3f00a1_0",
        reference_type_id: ReferenceType.first.id,
        url: "https://example.com"
      }}
    end

    assert_redirected_to admin_document_document_references_url(@document)
  end

  test "should show document_reference" do
    get admin_document_document_reference_url(@document, @document_reference)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_document_document_reference_url(@document, @document_reference)
    assert_response :success
  end

  test "should update document_reference" do
    patch admin_document_document_reference_url(@document, @document_reference), params: {
      document_reference: {
        friendlier_id: "35c8a641589c4e13b7aa11e37f3f00a1_0",
        reference_type_id: ReferenceType.first.id,
        url: "https://example2.com"
      }
    }
    assert_redirected_to admin_document_document_reference_url(@document, @document_reference)
  end

  test "should destroy document_reference" do
    assert_difference("DocumentReference.count", -1) do
      delete admin_document_document_reference_url(@document, @document_reference)
    end

    assert_redirected_to admin_document_document_references_url(@document)
  end

  test "should import references successfully" do
    post import_admin_document_references_url(@document), params: {document_id: @document.friendlier_id, document_reference: {references: {file: @file}}}
    assert_redirected_to admin_document_document_references_path(@document)
    assert_equal "References were created successfully.", flash[:notice]
  end

  test "should not import references with invalid file" do
    post import_admin_document_references_url(@document), params: {document_id: @document.friendlier_id, document_reference: {references: {file: nil}}}
    assert_redirected_to admin_document_document_references_path(@document)
    assert_equal "References could not be created. File does not exist or is invalid.", flash[:notice]
  end
end
