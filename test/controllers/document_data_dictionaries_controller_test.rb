require "test_helper"

class DocumentDataDictionariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @document = documents(:ag)
    @document_data_dictionary = document_data_dictionaries(:one)
    @file = fixture_file_upload("btaa_sample_document_data_dictionary_entries.csv", "text/csv")

    get "/users/sign_in"
    sign_in_as users(:user_001)
    post user_session_url

    follow_redirect!
    assert_response :success
  end

  test "should get index" do
    get admin_document_document_data_dictionaries_url(@document)
    assert_response :success
  end

  test "should get new" do
    get new_admin_document_document_data_dictionary_url(@document)
    assert_response :success
  end

  test "should create document_data_dictionary" do
    skip("@TODO: add file upload to test")
    assert_difference("DocumentDataDictionary.count") do
      post admin_document_document_data_dictionaries_url(@document), params: {
        document_data_dictionary: {
          friendlier_id: "35c8a641589c4e13b7aa11e37f3f00a1_0",
          name: "Created Dictionary",
          description: "Created Description",
          staff_notes: "Created Staff Notes",
          tags: "tag1,tag2,tag3",
          csv_file: @file
        }
      }
    end

    assert_redirected_to admin_document_document_data_dictionaries_url(@document)
  end

  test "should show document_data_dictionary" do
    get admin_document_document_data_dictionary_url(@document, @document_data_dictionary)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_document_document_data_dictionary_url(@document, @document_data_dictionary)
    assert_response :success
  end

  test "should update document_data_dictionary" do
    skip("@TODO: add file upload to test")
    patch admin_document_document_data_dictionary_url(@document, @document_data_dictionary), params: {
      document_data_dictionary: {
        friendlier_id: "35c8a641589c4e13b7aa11e37f3f00a1_0",
        name: "Updated Dictionary",
        description: "Updated Description",
        staff_notes: "Updated Staff Notes",
        tags: "tag1,tag2,tag3",
        csv_file: @file
      }
    }
    assert_redirected_to admin_document_document_data_dictionaries_url(@document)
  end

  test "should destroy document_data_dictionary" do
    assert_difference("DocumentDataDictionary.count", -1) do
      delete admin_document_document_data_dictionary_url(@document, @document_data_dictionary)
    end

    assert_redirected_to admin_document_document_data_dictionaries_url(@document)
  end

  test "should import data dictionary successfully" do
    skip("@TODO: add file upload to test")
    post import_admin_document_document_data_dictionaries_url(@document), params: {
      document_id: @document.friendlier_id,
      document_data_dictionary: {
        data_dictionary: {
          file: @file
        }
      }
    }
    assert_redirected_to admin_document_document_data_dictionaries_path(@document)
    assert_equal "Data dictionary was created successfully.", flash[:notice]
  end

  test "should not import data dictionary with invalid file" do
    post import_admin_document_document_data_dictionaries_url(@document), params: {document_id: @document.friendlier_id, document_data_dictionary: {data_dictionary: {file: nil}}}
    assert_redirected_to admin_document_document_data_dictionaries_path(@document)
    assert_equal "Data dictionaries could not be created. File does not exist or is invalid.", flash[:notice]
  end
end
