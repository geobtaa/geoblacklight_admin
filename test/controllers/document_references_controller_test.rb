require "test_helper"

class DocumentReferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @document_reference = document_references(:one)
  end

  test "should get index" do
    get document_references_url
    assert_response :success
  end

  test "should get new" do
    get new_document_reference_url
    assert_response :success
  end

  test "should create document_reference" do
    assert_difference("DocumentReference.count") do
      post document_references_url, params: { document_reference: {} }
    end

    assert_redirected_to document_reference_url(DocumentReference.last)
  end

  test "should show document_reference" do
    get document_reference_url(@document_reference)
    assert_response :success
  end

  test "should get edit" do
    get edit_document_reference_url(@document_reference)
    assert_response :success
  end

  test "should update document_reference" do
    patch document_reference_url(@document_reference), params: { document_reference: {} }
    assert_redirected_to document_reference_url(@document_reference)
  end

  test "should destroy document_reference" do
    assert_difference("DocumentReference.count", -1) do
      delete document_reference_url(@document_reference)
    end

    assert_redirected_to document_references_url
  end
end
