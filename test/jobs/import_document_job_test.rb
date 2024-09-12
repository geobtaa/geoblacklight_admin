# frozen_string_literal: true

require "test_helper"

class ImportDocumentJobTest < ActiveJob::TestCase
  setup do
    @import_document = import_documents(:ag)
    @document = Document.new(friendlier_id: @import_document.friendlier_id)
  end

  test "should update document and transition to success" do
    Document.stub(:where, [@document]) do
      @document.stub(:update, true) do
        perform_enqueued_jobs do
          ImportDocumentJob.perform_now(@import_document)
        end

        assert_equal :success, @import_document.state_machine.current_state.to_sym
      end
    end
  end

  test "should transition to failed on update failure" do
    Document.stub(:where, [@document]) do
      @document.stub(:update, false) do
        perform_enqueued_jobs do
          ImportDocumentJob.perform_now(@import_document)
        end

        assert_equal :failed, @import_document.state_machine.current_state.to_sym
      end
    end
  end

  test "should handle exceptions and transition to failed" do
    Document.stub(:where, [@document]) do
      @document.stub(:update, -> { raise "Simulated error" }) do
        perform_enqueued_jobs do
          ImportDocumentJob.perform_now(@import_document)
        end

        assert_equal :failed, @import_document.state_machine.current_state.to_sym
      end
    end
  end
end
