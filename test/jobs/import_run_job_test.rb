# frozen_string_literal: true

require "test_helper"

class ImportRunJobTest < ActiveJob::TestCase
  setup do
    @import = imports(:one) # Assuming a fixture or factory for imports

    # Stub the csv_file download to return CSV content
    def @import.csv_file
      OpenStruct.new(download: <<~CSV)
        title,id
        "Document Title 1","1"
        "Document Title 2","2"
      CSV
    end

    # Stub the convert_data method to just return the input hash
    def @import.convert_data(hash)
      hash
    end

    # Perform the job
    perform_enqueued_jobs do
      ImportRunJob.perform_now(@import)
    end
  end

  test "should create ImportDocuments for each CSV row" do
    assert_equal 2, ImportDocument.count
    assert ImportDocument.exists?(friendlier_id: "1")
    assert ImportDocument.exists?(friendlier_id: "2")
  end

  test "should enqueue ImportDocumentJob for each ImportDocument" do
    assert_enqueued_jobs 2, only: ImportDocumentJob
  end

  test "should handle CSV parsing errors gracefully" do
    # Adjust the CSV content to simulate an error
    @import.csv_file.define_singleton_method(:download) { "title,id\nInvalid row" }

    # Perform the job with the erroneous content
    assert_nothing_raised do
      perform_enqueued_jobs do
        ImportRunJob.perform_now(@import)
      end
    end

    # Ensure no ImportDocuments were created
    assert_equal 0, ImportDocument.count
  end

  test "logs errors without stopping the job" do
    # Stub convert_data to raise an error
    def @import.convert_data(_)
      raise "Simulated error"
    end

    # Perform the job and check that it handles the error
    assert_nothing_raised do
      perform_enqueued_jobs do
        ImportRunJob.perform_now(@import)
      end
    end

    # No ImportDocuments should be created due to the error
    assert_equal 0, ImportDocument.count
  end
end
