# frozen_string_literal: true

require "test_helper"

module Import
  class CsvHeaderValidatorTest < ActiveSupport::TestCase
    include ActionDispatch::TestProcess

    test "validate - no duplicate IDs allow" do
      skip("file download missing in test runner")
      @import = Import.new(
        name: "Test Header Validity",
        csv_file: fixture_file_upload("#{Rails.root}/test/fixtures/files/duplicate_ids.csv", "text/csv")
      )

      @import.run_callbacks(:commit)
      @import.save

      assert @import.invalid?
      assert @import.errors
    end
  end
end
