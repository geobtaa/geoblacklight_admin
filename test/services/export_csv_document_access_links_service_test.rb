# frozen_string_literal: true

require "test_helper"

class ExportCsvDocumentAccessLinksServiceTest < ActiveSupport::TestCase
  setup do
    @document = documents(:ag)
    @document_access = document_accesses(:one)
    @document_access.document = @document
    @document_access.save!
  end

  test "should return the correct short name" do
    assert_equal "Document Access Links", ExportCsvDocumentAccessLinksService.short_name
  end

  test "should generate CSV for document access links" do
    document_ids = [@document.friendlier_id]

    # Stubbing the ActionCable broadcast method
    ActionCable.server.stub(:broadcast, true) do
      csv_output = ExportCsvDocumentAccessLinksService.call(document_ids)

      # Check that CSV has headers matching the DocumentAccess column names
      assert_equal DocumentAccess.column_names, csv_output.first

      # Check that CSV contains the correct data for document accesses
      assert_includes csv_output, @document_access.to_csv
    end
  end

  test "should broadcast progress updates correctly" do
    document_ids = Array.new(300, @document.friendlier_id) # Simulate many documents

    broadcasted_progress = []
    ActionCable.server.stub(:broadcast, ->(_channel, data) { broadcasted_progress << data[:progress] }) do
      ExportCsvDocumentAccessLinksService.call(document_ids)
    end

    # Check that progress updates were broadcasted correctly
    assert_includes broadcasted_progress, 0
    assert_includes broadcasted_progress, 100
    assert broadcasted_progress.all? { |progress| progress.between?(0, 100) }
  end

  test "should handle missing documents gracefully" do
    missing_document_id = "missing_id"

    # Stubbing the ActionCable broadcast method
    ActionCable.server.stub(:broadcast, true) do
      csv_output = ExportCsvDocumentAccessLinksService.call([missing_document_id])

      # Ensure that the output is empty since no valid accesses were found
      assert_empty csv_output
    end
  end
end
