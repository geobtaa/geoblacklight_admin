require "test_helper"

class DocumentReferenceTest < ActiveSupport::TestCase
  def setup
    @document_reference = DocumentReference.new(
      friendlier_id: documents(:ls).friendlier_id,
      reference_type_id: ReferenceType.first.id,
      url: "http://example.com",
      label: "Example Label"
    )
  end

  test "should be valid" do
    assert @document_reference.valid?
  end

  test "friendlier_id should be present" do
    @document_reference.friendlier_id = nil
    assert_not @document_reference.valid?
  end

  test "reference_type should be present" do
    @document_reference.reference_type = nil
    assert_not @document_reference.valid?
  end

  test "url should be present" do
    @document_reference.url = nil
    assert_not @document_reference.valid?
  end

  test "url should be unique scoped to friendlier_id and reference_type_id" do
    duplicate_reference = @document_reference.dup
    @document_reference.save
    assert_not duplicate_reference.valid?
  end

  test "should convert to CSV" do
    expected_csv = [
      @document_reference.friendlier_id,
      @document_reference.reference_type.name,
      @document_reference.url,
      @document_reference.label
    ]
    assert_equal expected_csv, @document_reference.to_csv
  end

  test "should convert to aardvark reference" do
    expected_aardvark = {
      @document_reference.reference_type.reference_uri.to_s => @document_reference.url
    }
    expected_aardvark[:label] = @document_reference.label if @document_reference.reference_type.reference_uri.to_s == "http://schema.org/downloadUrl"
    assert_equal expected_aardvark, @document_reference.to_aardvark_reference
  end

  test "should import from CSV" do
    file_path = File.expand_path("../../../test/fixtures/files/import_references.csv", __FILE__)
    file = File.open(file_path)
    assert_difference "DocumentReference.count", 3 do
      DocumentReference.import(file)
    end
  end

  test "should destroy all from CSV" do
    file_path = File.expand_path("../../../test/fixtures/files/import_references.csv", __FILE__)
    file = File.open(file_path)
    DocumentReference.import(file)
    assert_difference "DocumentReference.count", -3 do
      DocumentReference.destroy_all(file)
    end
  end

  test "should reindex document after save" do
    document = documents(:ag)
    @document_reference.document = document
    @document_reference.save
    assert document.saved_changes?
  end

  # Add more tests for edge cases and other methods as needed
end
