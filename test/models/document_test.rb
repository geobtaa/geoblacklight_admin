require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should not save document without title" do
    document = Document.new
    assert_not document.save, "Saved the document without a title"
  end

  test "should save document with minimal required attributes" do
    document = Document.new

    # Required attributes
    document.title = "Test Document"
    document.gbl_resourceClass_sm = ["Dataset"]
    document.geomg_id_s = "123456"
    document.dct_accessRights_s = "Public"

    assert document.save
  end

  # @TODO
  # Test the presence of the reference values
  # - From: Aardvark, Multiple Download Links, and Additional Assets
end