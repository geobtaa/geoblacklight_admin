# frozen_string_literal: true

class ExportCsvDocumentLicensedAccessLinksServiceTest < ActiveSupport::TestCase
  setup do
    @document1 = documents(:one)
    @document2 = documents(:two)
    @access1 = DocumentLicensedAccess.create!(document: @document1, institution_code: 1, access_url: "http://b1g.com/")
    @access2 = DocumentLicensedAccess.create!(document: @document1, institution_code: 2, access_url: "https://btaa.org")
    @access3 = DocumentLicensedAccess.create!(document: @document2, institution_code: 3, access_url: "https://geo.btaa.org")
  end

  test "short_name returns expected value" do
    assert_equal "Document Licensed Access Links", ExportCsvDocumentLicensedAccessLinksService.short_name
  end

  test "call returns CSV with headers and data" do
    document_ids = [@document1.id, @document2.id]
    result = ExportCsvDocumentLicensedAccessLinksService.call(document_ids)

    # Parse the CSV
    csv_rows = CSV.parse(result)

    # Check headers
    assert_equal DocumentLicensedAccess.column_names, csv_rows[0]

    # Check data
    assert_equal 4, csv_rows.length # header + 3 rows
    assert_includes result, "http://b1g.com/"
    assert_includes result, "https://btaa.org"
    assert_includes result, "https://geo.btaa.org"
  end

  test "call returns empty CSV with headers when no documents found" do
    document_ids = [-1] # Non-existent ID
    result = ExportCsvDocumentLicensedAccessLinksService.call(document_ids)

    # Parse the CSV
    csv_rows = CSV.parse(result)

    # Should have headers but no data
    assert_equal 1, csv_rows.length
    assert_equal DocumentLicensedAccess.column_names, csv_rows[0]
  end

  test "call handles nil document_ids" do
    assert_nothing_raised do
      ExportCsvDocumentLicensedAccessLinksService.call(nil)
    end
  end
end 