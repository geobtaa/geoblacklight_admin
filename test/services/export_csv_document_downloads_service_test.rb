require "test_helper"

class ExportCsvDocumentDownloadsServiceTest < ActiveSupport::TestCase
  def setup
    @document1 = Document.create!(geomg_id_s: "doc1", friendlier_id: "doc1", title: "Document 1", gbl_resourceClass_sm: ["Map"], dct_accessRights_s: "Public")
    @document2 = Document.create!(geomg_id_s: "doc2", friendlier_id: "doc2", title: "Document 2", gbl_resourceClass_sm: ["Map"], dct_accessRights_s: "Public")
    @download1 = @document1.document_downloads.create!(
      friendlier_id: "doc1",
      label: "KMZ",
      value: "https://cugir-data.s3.amazonaws.com/00/79/50/agBROO2011.kmz"
    )
    @download2 = @document2.document_downloads.create!(
      friendlier_id: "doc2",
      label: "KMZ",
      value: "https://cugir-data.s3.amazonaws.com/00/79/50/agBROO2011.kmz"
    )
  end

  def test_short_name
    assert_equal "Document Downloads", ExportCsvDocumentDownloadsService.short_name
  end

  def test_call
    document_ids = [@document1.friendlier_id, @document2.friendlier_id]
    csv_output = ExportCsvDocumentDownloadsService.call(document_ids)

    assert_includes csv_output, DocumentDownload.column_names
    assert_includes csv_output, @download1.to_csv
    assert_includes csv_output, @download2.to_csv
  end
end
