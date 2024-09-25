require "test_helper"

class ExportCsvDocumentAccessLinksServiceTest < ActiveSupport::TestCase
  setup do
    @document1 = Document.create!(geomg_id_s: "doc1", friendlier_id: "doc1", title: "Document 1", gbl_resourceClass_sm: ["Map"], dct_accessRights_s: "Public")
    @document2 = Document.create!(geomg_id_s: "doc2", friendlier_id: "doc2", title: "Document 2", gbl_resourceClass_sm: ["Map"], dct_accessRights_s: "Public")
    @access1 = DocumentAccess.create!(document: @document1, institution_code: 1, access_url: "http://b1g.com/")
    @access2 = DocumentAccess.create!(document: @document1, institution_code: 1, access_url: "https://btaa.org")
    @access3 = DocumentAccess.create!(document: @document2, institution_code: 2, access_url: "https://geo.btaa.org")
  end

  test "short_name returns correct value" do
    assert_equal "Document Access Links", ExportCsvDocumentAccessLinksService.short_name
  end

  test "call generates CSV with correct headers and data" do
    document_ids = [@document1.friendlier_id, @document2.friendlier_id]
    result = ExportCsvDocumentAccessLinksService.call(document_ids)

    csv_string = CSV.generate do |csv|
      result.each do |row|
        csv << row
      end
    end

    csv_rows = CSV.parse(csv_string)
    assert_equal DocumentAccess.column_names, csv_rows[0]
    assert_equal 4, csv_rows.size # Header + 3 document accesses

    # Collect IDs from csv_rows
    ids_from_csv = csv_rows[1..].map { |row| row[0] }

    assert_includes ids_from_csv, @access1.id.to_s, "CSV does not include @access1 id"
    assert_includes ids_from_csv, @access2.id.to_s, "CSV does not include @access2 id"
    assert_includes ids_from_csv, @access3.id.to_s, "CSV does not include @access3 id"
  end

  test "call handles non-existent documents" do
    document_ids = [@document1.friendlier_id, "non_existent_id"]
    result = ExportCsvDocumentAccessLinksService.call(document_ids)

    csv_string = CSV.generate do |csv|
      result.each do |row|
        csv << row
      end
    end

    csv_rows = CSV.parse(csv_string)
    assert_equal 3, csv_rows.size # Header + 2 document accesses for @document1
  end

  test "call broadcasts progress" do
    document_ids = [@document1.friendlier_id, @document2.friendlier_id]

    broadcast_calls = []

    ActionCable.server.stub(:broadcast, ->(channel, data) { broadcast_calls << [channel, data] }) do
      ExportCsvDocumentAccessLinksService.call(document_ids)
    end

    assert_equal 2, broadcast_calls.size, "Expected 2 broadcast calls, but got #{broadcast_calls.size}"
    assert_equal ["export_channel", {progress: 0}], broadcast_calls[0], "First broadcast call doesn't match expected"
    assert_equal ["export_channel", {progress: 100}], broadcast_calls[1], "Second broadcast call doesn't match expected"
  end
end
